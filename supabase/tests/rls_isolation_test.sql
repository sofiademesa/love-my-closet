-- =============================================================================
-- User-isolation tests for the Love My Closet schema.
-- Every block raises an exception (and stops the script) if a check fails.
--
-- Run against a LOCAL / throwaway database only (e.g. `supabase start`, then
-- `psql "$LOCAL_DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/rls_isolation_test.sql`).
-- It creates two users in auth.users, so never run it against production.
-- =============================================================================

\set alice '11111111-1111-1111-1111-111111111111'
\set bob   '22222222-2222-2222-2222-222222222222'

-- Sign-up (as the auth system would do it)
insert into auth.users (id, email, raw_user_meta_data) values
  (:'alice', 'alice@example.com', '{"display_name":"Alice","full_name":"Alice Doe"}'),
  (:'bob',   'bob@example.com',   '{"display_name":"Bob","full_name":"Bob Roe"}');

do $$ begin
  assert (select display_name from public.profiles where id = '11111111-1111-1111-1111-111111111111') = 'Alice',
    'signup trigger should create a profile from user metadata';
  raise notice 'PASS profile auto-created on sign-up';
end $$;

-- ---------------------------------------------------------------- Alice acts
set role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);

insert into public.clothing_items (id, name, category, occasion, color, image_path)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'Pink Top', 'Tops', 'Everyday', 'Pink',
        '11111111-1111-1111-1111-111111111111/a1.png'),
       ('aaaaaaaa-0000-0000-0000-000000000002', 'Blue Skirt', 'Bottoms', 'Party', 'Blue', null);

insert into storage.objects (bucket_id, name)
values ('clothing-images', '11111111-1111-1111-1111-111111111111/a1.png');

create temp table alice_save as
select * from public.save_outfit(
  null, 'Library Run',
  '[{"clothing_item_id":"aaaaaaaa-0000-0000-0000-000000000001","position_x":10,"position_y":20},
    {"clothing_item_id":"aaaaaaaa-0000-0000-0000-000000000002","position_x":30,"position_y":40}]',
  null, date '2026-09-29');
grant select on alice_save to authenticated;

do $$ begin
  assert (select count(*) from public.outfit_items) = 2, 'Alice should have 2 pieces';
  assert (select count(*) from public.calendar_entries where worn_on = date '2026-09-29') = 1,
    'save_outfit should schedule the outfit on the calendar';
  raise notice 'PASS Alice: item, image, outfit, pieces, calendar entry saved';
end $$;

-- Update: rename, move to another date, add a diary note, keep pieces.
select * from public.save_outfit(
  (select outfit_id from alice_save), 'Library Run 2', null,
  (select entry_id from alice_save), date '2026-10-02', 'Felt cozy', true);

do $$ begin
  assert (select name from public.outfits) = 'Library Run 2', 'rename failed';
  assert (select worn_on from public.calendar_entries) = date '2026-10-02', 'reschedule failed';
  assert (select note from public.calendar_entries) = 'Felt cozy', 'diary note not saved';
  assert (select count(*) from public.outfit_items) = 2, 'pieces must be untouched when p_pieces is null';
  raise notice 'PASS Alice: outfit edited, rescheduled, diary note saved';
end $$;

-- Updating the date again WITHOUT p_update_note must keep the note.
select * from public.save_outfit(
  (select outfit_id from alice_save), 'Library Run 2',
  '[{"clothing_item_id":"aaaaaaaa-0000-0000-0000-000000000001","position_x":1,"position_y":2}]',
  (select entry_id from alice_save), date '2026-10-03');
do $$ begin
  assert (select note from public.calendar_entries) = 'Felt cozy', 'note must survive a builder update';
  assert (select count(*) from public.outfit_items) = 1, 'pieces should be replaced';
  raise notice 'PASS Alice: builder update replaces pieces and keeps the diary note';
end $$;

-- Image path must be inside your own folder.
do $$ begin
  begin
    insert into public.clothing_items (name, category, image_path)
    values ('Sneaky', 'Tops', '22222222-2222-2222-2222-222222222222/x.png');
    raise exception 'FAIL: image_path in another user''s folder was accepted';
  exception when check_violation then
    raise notice 'PASS image_path outside own folder rejected';
  end;
end $$;

-- ------------------------------------------------------------------ Bob acts
select set_config('request.jwt.claim.sub', '22222222-2222-2222-2222-222222222222', false);

do $$
declare n int;
begin
  assert (select count(*) from public.clothing_items) = 0, 'Bob can see Alice''s items';
  assert (select count(*) from public.outfits) = 0, 'Bob can see Alice''s outfits';
  assert (select count(*) from public.outfit_items) = 0, 'Bob can see Alice''s outfit pieces';
  assert (select count(*) from public.calendar_entries) = 0, 'Bob can see Alice''s calendar';
  assert (select count(*) from public.profiles) = 1, 'Bob should only see his own profile';
  assert (select count(*) from storage.objects) = 0, 'Bob can see Alice''s images';
  raise notice 'PASS Bob cannot read any of Alice''s rows or images';

  update public.clothing_items set name = 'hacked' where id = 'aaaaaaaa-0000-0000-0000-000000000001';
  get diagnostics n = row_count; assert n = 0, 'Bob updated Alice''s item';
  update public.clothing_items set is_favorite = true;
  get diagnostics n = row_count; assert n = 0, 'Bob favorited Alice''s item';
  delete from public.clothing_items;
  get diagnostics n = row_count; assert n = 0, 'Bob deleted Alice''s items';
  delete from public.calendar_entries;
  get diagnostics n = row_count; assert n = 0, 'Bob deleted Alice''s diary';
  update public.profiles set bio = 'hacked' where id = '11111111-1111-1111-1111-111111111111';
  get diagnostics n = row_count; assert n = 0, 'Bob edited Alice''s profile';
  raise notice 'PASS Bob cannot update or delete Alice''s rows or profile';
end $$;

do $$
declare n int;
begin
  begin
    delete from storage.objects;
    get diagnostics n = row_count;
    assert n = 0, 'Bob deleted Alice''s image';
  exception when assert_failure then raise;
  when others then
    -- Newer Supabase versions block direct SQL deletes on storage tables
    -- entirely; that also means Bob can't delete the image.
    null;
  end;
  raise notice 'PASS Bob cannot delete Alice''s images';
end $$;

do $$ begin
  begin
    insert into public.clothing_items (user_id, name, category)
    values ('11111111-1111-1111-1111-111111111111', 'Planted', 'Tops');
    raise exception 'FAIL: Bob inserted a row owned by Alice';
  exception when insufficient_privilege then
    raise notice 'PASS Bob cannot insert rows as Alice';
  end;

  begin
    insert into storage.objects (bucket_id, name)
    values ('clothing-images', '11111111-1111-1111-1111-111111111111/evil.png');
    raise exception 'FAIL: Bob uploaded into Alice''s folder';
  exception when insufficient_privilege then
    raise notice 'PASS Bob cannot upload into Alice''s storage folder';
  end;

  begin
    perform public.save_outfit(null, 'Stolen',
      '[{"clothing_item_id":"aaaaaaaa-0000-0000-0000-000000000001","position_x":0,"position_y":0}]',
      null, date '2026-09-29');
    raise exception 'FAIL: Bob put Alice''s clothing item in his outfit';
  exception when foreign_key_violation then
    raise notice 'PASS Bob cannot use Alice''s clothing item in an outfit';
  end;

  begin
    perform public.save_outfit((select outfit_id from alice_save), 'Hijack', null, null, null);
    raise exception 'FAIL: Bob renamed Alice''s outfit via save_outfit';
  exception when no_data_found then
    raise notice 'PASS Bob cannot edit Alice''s outfit through save_outfit';
  end;

  begin
    insert into public.calendar_entries (outfit_id, worn_on)
    values ((select outfit_id from alice_save), date '2026-09-30');
    raise exception 'FAIL: Bob logged a diary entry on Alice''s outfit';
  exception when foreign_key_violation then
    raise notice 'PASS Bob cannot attach diary entries to Alice''s outfit';
  end;
end $$;

-- ------------------------------------------------------------ not signed in
reset role;
set role anon;
select set_config('request.jwt.claim.sub', '', false);
do $$ begin
  begin
    perform count(*) from public.clothing_items;
    raise exception 'FAIL: anon can query clothing_items';
  exception when insufficient_privilege then
    raise notice 'PASS signed-out visitors cannot read any table';
  end;
end $$;

-- -------------------------------------------------- cascade on item delete
reset role;
set role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);
delete from public.clothing_items where id = 'aaaaaaaa-0000-0000-0000-000000000001';
do $$ begin
  assert (select count(*) from public.outfit_items) = 0, 'deleting an item should remove it from outfits';
  assert (select count(*) from public.outfits) = 1, 'the outfit itself should remain';
  raise notice 'PASS deleting a closet item removes it from outfits (outfit kept)';
end $$;

reset role;
do $$ begin raise notice 'ALL RLS ISOLATION TESTS PASSED'; end $$;
