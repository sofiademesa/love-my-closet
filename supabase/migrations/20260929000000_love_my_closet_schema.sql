-- =============================================================================
-- Love My Closet - Supabase backend schema
-- =============================================================================
-- Run once in the Supabase Dashboard (SQL Editor > New query > paste > Run),
-- or with the Supabase CLI: `supabase db push`.
--
-- Everything a user owns carries a user_id that references auth.users and is
-- protected by Row Level Security, so each signed-in user can only ever see or
-- change their own rows. Child tables use composite foreign keys
-- (id, user_id) so a row can never point at another user's closet item or
-- outfit, even if someone guessed its id.
--
-- Tables
--   profiles           1 per auth user (display name, bio, closet settings)
--   clothing_items     the Digital Closet (image lives in Storage)
--   outfits            a saved look from the Outfit Builder
--   outfit_items       which closet pieces are on an outfit's board, and where
--   calendar_entries   an outfit on a date, with an optional diary note
--
-- Favorites are the `is_favorite` flag on clothing_items: every item has
-- exactly one owner, so a separate favorites table would only duplicate it.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- profiles
-- -----------------------------------------------------------------------------

create table if not exists public.profiles (
  id                     uuid primary key references auth.users (id) on delete cascade,
  display_name           text not null default '' check (char_length(display_name) <= 80),
  full_name              text not null default '' check (char_length(full_name) <= 120),
  bio                    text not null default '' check (char_length(bio) <= 300),
  notifications_enabled  boolean not null default true,
  hidden_gems_threshold_days integer not null default 30
                           check (hidden_gems_threshold_days in (7, 14, 30, 60, 90)),
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Create the profile row automatically when someone signs up. The Create
-- Account screen passes full_name / display_name as user metadata.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, full_name)
  values (
    new.id,
    left(coalesce(nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''),
                  split_part(coalesce(new.email, ''), '@', 1)), 80),
    left(coalesce(trim(new.raw_user_meta_data ->> 'full_name'), ''), 120)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- -----------------------------------------------------------------------------
-- clothing_items
-- -----------------------------------------------------------------------------

create table if not exists public.clothing_items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text not null check (char_length(trim(name)) between 1 and 80),
  category    text not null
                check (category in ('Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Shoes', 'Accessories')),
  occasion    text not null default 'Everyday'
                check (occasion in ('Everyday', 'Formal', 'Party')),
  color       text not null default 'Transparent'
                check (color in ('Pink', 'Yellow', 'Blue', 'Denim', 'White', 'Black', 'Multicolor', 'Transparent')),
  -- Object path inside the private `clothing-images` bucket. Always inside
  -- the owner's own folder: "<user_id>/<file>.png".
  image_path  text check (image_path is null or image_path like user_id::text || '/%'),
  is_favorite boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (id, user_id)
);

create index if not exists clothing_items_user_created_idx
  on public.clothing_items (user_id, created_at desc);

drop trigger if exists clothing_items_set_updated_at on public.clothing_items;
create trigger clothing_items_set_updated_at
  before update on public.clothing_items
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- outfits + outfit_items
-- -----------------------------------------------------------------------------

create table if not exists public.outfits (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text not null check (char_length(trim(name)) between 1 and 80),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (id, user_id)
);

create index if not exists outfits_user_idx on public.outfits (user_id);

drop trigger if exists outfits_set_updated_at on public.outfits;
create trigger outfits_set_updated_at
  before update on public.outfits
  for each row execute function public.set_updated_at();

create table if not exists public.outfit_items (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null default auth.uid() references auth.users (id) on delete cascade,
  outfit_id         uuid not null,
  clothing_item_id  uuid not null,
  -- Where the piece sits on the Builder board (logical pixels) and its
  -- stacking order (higher = drawn on top).
  position_x        double precision not null default 0,
  position_y        double precision not null default 0,
  -- Size relative to the default board size (1 = default), from resizing.
  scale             double precision not null default 1
                      constraint outfit_items_scale_range check (scale between 0.4 and 3.0),
  sort_order        integer not null default 0,
  created_at        timestamptz not null default now(),
  foreign key (outfit_id, user_id)
    references public.outfits (id, user_id) on delete cascade,
  foreign key (clothing_item_id, user_id)
    references public.clothing_items (id, user_id) on delete cascade
);

-- Projects created before piece resizing existed get the column on re-run.
alter table public.outfit_items
  add column if not exists scale double precision not null default 1
    constraint outfit_items_scale_range check (scale between 0.4 and 3.0);

create index if not exists outfit_items_outfit_idx on public.outfit_items (outfit_id, sort_order);
create index if not exists outfit_items_item_idx on public.outfit_items (clothing_item_id);
create index if not exists outfit_items_user_idx on public.outfit_items (user_id);

-- -----------------------------------------------------------------------------
-- calendar_entries (Calendar + Outfit Diary)
-- -----------------------------------------------------------------------------

create table if not exists public.calendar_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  outfit_id   uuid not null,
  worn_on     date not null,
  note        text check (note is null or char_length(note) <= 2000),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  foreign key (outfit_id, user_id)
    references public.outfits (id, user_id) on delete cascade
);

create index if not exists calendar_entries_user_date_idx
  on public.calendar_entries (user_id, worn_on);
create index if not exists calendar_entries_outfit_idx
  on public.calendar_entries (outfit_id);

drop trigger if exists calendar_entries_set_updated_at on public.calendar_entries;
create trigger calendar_entries_set_updated_at
  before update on public.calendar_entries
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Row Level Security
-- -----------------------------------------------------------------------------
-- `(select auth.uid())` instead of `auth.uid()` lets Postgres evaluate it once
-- per statement (Supabase's recommended form).

alter table public.profiles         enable row level security;
alter table public.clothing_items   enable row level security;
alter table public.outfits          enable row level security;
alter table public.outfit_items     enable row level security;
alter table public.calendar_entries enable row level security;

-- profiles: read/insert/update your own row only. No client deletes (the
-- row goes away with the auth user via ON DELETE CASCADE).
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Owner-only CRUD for every user-owned table.
do $$
declare
  t text;
begin
  foreach t in array array['clothing_items', 'outfits', 'outfit_items', 'calendar_entries'] loop
    execute format('drop policy if exists %I on public.%I', t || '_select_own', t);
    execute format(
      'create policy %I on public.%I for select to authenticated using ((select auth.uid()) = user_id)',
      t || '_select_own', t);

    execute format('drop policy if exists %I on public.%I', t || '_insert_own', t);
    execute format(
      'create policy %I on public.%I for insert to authenticated with check ((select auth.uid()) = user_id)',
      t || '_insert_own', t);

    execute format('drop policy if exists %I on public.%I', t || '_update_own', t);
    execute format(
      'create policy %I on public.%I for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)',
      t || '_update_own', t);

    execute format('drop policy if exists %I on public.%I', t || '_delete_own', t);
    execute format(
      'create policy %I on public.%I for delete to authenticated using ((select auth.uid()) = user_id)',
      t || '_delete_own', t);
  end loop;
end;
$$;

-- The anon role (not signed in) gets nothing at all.
revoke all on public.profiles, public.clothing_items, public.outfits,
              public.outfit_items, public.calendar_entries from anon;
grant select, insert, update, delete on public.clothing_items, public.outfits,
              public.outfit_items, public.calendar_entries to authenticated;
grant select, insert, update on public.profiles to authenticated;

-- -----------------------------------------------------------------------------
-- save_outfit(): create or update an outfit, its board pieces and its
-- calendar entry in ONE transaction (the Builder's "Save Outfit" /
-- "Update Outfit", and the Calendar's "Edit Details").
--
-- SECURITY INVOKER: runs with the caller's permissions, so every statement
-- inside is still filtered by the RLS policies above.
--
--   p_outfit_id    null = new outfit, otherwise the outfit to update
--   p_name         outfit name
--   p_pieces       null = leave pieces alone, otherwise the full new board:
--                  [{"clothing_item_id": uuid, "position_x": n, "position_y": n}, ...]
--                  in stacking order (last = on top)
--   p_entry_id     null = new calendar entry, otherwise the entry to update
--   p_worn_on      the calendar date (null = don't touch the calendar)
--   p_note         diary note, applied only when p_update_note is true
-- -----------------------------------------------------------------------------

create or replace function public.save_outfit(
  p_outfit_id   uuid,
  p_name        text,
  p_pieces      jsonb,
  p_entry_id    uuid,
  p_worn_on     date,
  p_note        text default null,
  p_update_note boolean default false
)
returns table (outfit_id uuid, entry_id uuid)
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_outfit uuid := p_outfit_id;
  v_entry  uuid := p_entry_id;
begin
  if v_uid is null then
    raise exception 'Not signed in' using errcode = '42501';
  end if;

  if v_outfit is null then
    insert into public.outfits (user_id, name)
    values (v_uid, trim(p_name))
    returning id into v_outfit;
  else
    update public.outfits
       set name = trim(p_name)
     where id = v_outfit and user_id = v_uid;
    if not found then
      raise exception 'Outfit not found' using errcode = 'P0002';
    end if;
  end if;

  if p_pieces is not null then
    delete from public.outfit_items oi
     where oi.outfit_id = v_outfit and oi.user_id = v_uid;

    insert into public.outfit_items
      (user_id, outfit_id, clothing_item_id, position_x, position_y, scale, sort_order)
    select v_uid, v_outfit,
           (e.piece ->> 'clothing_item_id')::uuid,
           coalesce((e.piece ->> 'position_x')::double precision, 0),
           coalesce((e.piece ->> 'position_y')::double precision, 0),
           least(greatest(coalesce((e.piece ->> 'scale')::double precision, 1), 0.4), 3.0),
           (e.ord - 1)::integer
      from jsonb_array_elements(p_pieces) with ordinality as e(piece, ord);
  end if;

  if p_worn_on is not null then
    if v_entry is null then
      insert into public.calendar_entries (user_id, outfit_id, worn_on, note)
      values (v_uid, v_outfit, p_worn_on,
              case when p_update_note then nullif(trim(p_note), '') end)
      returning id into v_entry;
    else
      update public.calendar_entries ce
         set worn_on = p_worn_on,
             note = case when p_update_note then nullif(trim(p_note), '') else ce.note end
       where ce.id = v_entry and ce.user_id = v_uid and ce.outfit_id = v_outfit;
      if not found then
        raise exception 'Calendar entry not found' using errcode = 'P0002';
      end if;
    end if;
  end if;

  return query select v_outfit, v_entry;
end;
$$;

revoke all on function public.save_outfit(uuid, text, jsonb, uuid, date, text, boolean) from public, anon;
grant execute on function public.save_outfit(uuid, text, jsonb, uuid, date, text, boolean) to authenticated;

-- -----------------------------------------------------------------------------
-- Storage: private bucket for the transparent PNG cutouts
-- -----------------------------------------------------------------------------
-- Private (public = false): images are only reachable through short-lived
-- signed URLs that the owner requests. PNG only, 10 MB max.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('clothing-images', 'clothing-images', false, 10485760, array['image/png'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Files live at "<user_id>/<file>.png". Each policy checks that the first
-- folder of the path is the caller's own user id.
drop policy if exists "clothing_images_select_own" on storage.objects;
create policy "clothing_images_select_own" on storage.objects
  for select to authenticated
  using (bucket_id = 'clothing-images'
         and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "clothing_images_insert_own" on storage.objects;
create policy "clothing_images_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'clothing-images'
              and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "clothing_images_update_own" on storage.objects;
create policy "clothing_images_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'clothing-images'
         and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'clothing-images'
              and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "clothing_images_delete_own" on storage.objects;
create policy "clothing_images_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'clothing-images'
         and (storage.foldername(name))[1] = (select auth.uid())::text);