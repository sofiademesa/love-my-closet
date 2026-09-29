-- =============================================================================
-- Love My Closet: resizable pieces on the Outfit Builder board
-- =============================================================================
-- Run this ONCE on a project that already has
-- 20260929000000_love_my_closet_schema.sql applied (SQL Editor -> paste -> Run,
-- or `supabase db push`). Safe to run again.
--
-- What it changes:
--   * outfit_items.scale: each piece's size relative to its default size
--     (1 = default, allowed 0.4 - 3.0). Existing rows get 1, so saved
--     outfits look exactly as before.
--   * save_outfit(): same signature and permissions; now also stores each
--     piece's "scale" (missing -> 1, out of range -> clamped).
-- Nothing else (tables, RLS policies, storage) is touched.
-- =============================================================================

alter table public.outfit_items
  add column if not exists scale double precision not null default 1
    constraint outfit_items_scale_range check (scale between 0.4 and 3.0);

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

-- Let the API see the new column right away.
notify pgrst, 'reload schema';