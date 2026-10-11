# Security and privacy

This repository is public. Fill this in honestly and date it; it is checked as part of grading.

**Last checked: 2026-10-11**

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Account email and password (password stored only as a hash) | Supabase Auth | Only that user. As project owner I can see the email in the Supabase dashboard; I cannot see passwords. |
| Profile (display name, full name, bio, notifications setting, Hidden Gems threshold) | Supabase PostgreSQL, `profiles` table | Only that user (Row Level Security) |
| Clothing items (name, category, occasion, color, favorite flag, photo path) | Supabase PostgreSQL, `clothing_items` table | Only the user who owns the row (Row Level Security) |
| Saved outfits and their board layout (piece position, size, stacking order) | Supabase PostgreSQL, `outfits` and `outfit_items` tables | Only the user who owns the row (Row Level Security) |
| Calendar / Outfit Diary entries (date worn, optional note) | Supabase PostgreSQL, `calendar_entries` table | Only the user who owns the row (Row Level Security) |
| Clothing photos (background-removed PNG cutouts) | Supabase Storage, private `clothing-images` bucket, in a folder named after the user's id | Only the owner, through signed URLs that expire after 12 hours |
| Original photo before background removal | In memory in the browser only. Background removal runs on the device (silueta U²-Net model with ONNX Runtime Web), and only the finished cutout is uploaded. | Only that user. Never sent to any server or third-party AI service. |
| Login session tokens | Browser local storage when "Remember me" is on; in memory only when it is off | Only that user, on that browser |
| Accessibility settings (text size, reduce motion, high contrast) and UI state (filters, selected tab) | In memory on the device | Only that user; reset on reload |

## Secrets

Values my app needs at run time (names only):

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Where they live locally: `env.json` (git-ignored), passed with `--dart-define-from-file=env.json`. `.env`, `.env.*` and `env.json` are all in `.gitignore`, and `.env.example` is committed with placeholders only. `lib/services/supabase_config.dart` also has this project's URL and publishable key as default values, on purpose, so the app runs with no setup. This is safe because both values are public by design (see below).

Where the deploy workflow gets them: repository secrets (Settings > Secrets and variables > Actions). `.github/workflows/deploy-web.yml` reads `${{ secrets.SUPABASE_URL }}` and `${{ secrets.SUPABASE_PUBLISHABLE_KEY }}` and passes them to `flutter build web` with `--dart-define`. No value is written in the workflow file, and the run logs show them as `***`.

Anything my deployed web build carries that a visitor could read, and why that is acceptable: the Supabase project URL and the **publishable** key (`sb_publishable_...`, the successor to the anon key), protected by RLS. Supabase designs these to ship inside client apps: they only identify the project, and a visitor using them gets only what the policies below allow. That means nothing at all when signed out, and only their own rows when signed in. The secret / `service_role` key is not used anywhere in the app, the workflow or the repo, and the app refuses to start if it is given one by mistake. There are no other keys: background removal runs on the device, and the app uses no third-party APIs.

## What protects the data on the service side

Supabase RLS policies, from `supabase/migrations/20260929000000_love_my_closet_schema.sql`:

- **RLS is enabled on all five tables:** `profiles`, `clothing_items`, `outfits`, `outfit_items`, `calendar_entries`.
- **`clothing_items`, `outfits`, `outfit_items`, `calendar_entries`:** separate SELECT, INSERT, UPDATE and DELETE policies, all `to authenticated` and limited to `(select auth.uid()) = user_id`. INSERT and UPDATE also use `with check` with the same rule, so a user cannot create or move a row into someone else's name.
- **`profiles`:** SELECT, INSERT and UPDATE limited to `(select auth.uid()) = id`. There is no DELETE policy; the profile is removed automatically when the account is deleted.
- **Signed-out visitors:** the `anon` role has all privileges on these tables revoked, so they can read and write nothing.
- **Cross-user links blocked:** `outfit_items` and `calendar_entries` use composite foreign keys `(id, user_id)`, so an outfit can't include another user's clothing item and a diary entry can't point at another user's outfit, even with a guessed id.
- **`save_outfit()` function:** runs as `security invoker`, so RLS still applies inside it, and only signed-in users can call it.
- **Storage:** the `clothing-images` bucket is private (`public = false`), PNG only, 10 MB max. The four policies on `storage.objects` allow SELECT, INSERT, UPDATE and DELETE only when `bucket_id = 'clothing-images'` and the first folder in the path equals the signed-in user's id. The database also rejects an `image_path` outside the user's own folder.
- **Input limits enforced by the database, not only the UI:** name 1–80 characters, only allowed category/occasion/color values, diary note ≤ 2000 characters, bio ≤ 300, piece size 0.4–3.0.

How I tested it:

- **Automated two-user test:** `supabase/tests/rls_isolation_test.sql` creates two users (Alice and Bob) on a local database and checks that Bob cannot read, edit, delete, impersonate, upload into, or link to any of Alice's rows or photos, and that a signed-out visitor cannot query any table.
- **Live app (2026-10-05):** tested with two accounts. Account B could not see account A's items, outfits, diary entries or photos, and A's data was still there after logging back in.
- **Live API, signed out (2026-10-09):** using only the public publishable key, reading `/rest/v1/clothing_items` and inserting a fake item both returned 401 Unauthorized. Anonymous sign-ins are turned off.

## Checklist

- [x] `.env` (or `env.json`) is in `.gitignore`, and `.env.example` is committed. `.env`, `.env.*` and `env.json` are all ignored.
- [x] `git log -p | grep -i "api_key\|secret\|password\|token"` finds nothing real. Ran it on the full history on 2026-10-09. The only real value it finds is the public Supabase publishable key in `supabase_config.dart`, which is public by design and ships in every web build. Every other match is a placeholder, a fake test value, a variable name, or a `${{ secrets.… }}` reference. No secret or `service_role` key in any commit.
- [x] No service account file, keystore or `service_role` key anywhere in the repo. The app is web-only (no `android/` or `ios/` folder), and `*.jks`, `*.keystore` and `serviceAccountKey.json` are gitignored anyway.
- [x] Security rules or RLS policies written and tested, not left open (see above)
- [x] No real personal data in sample data, screenshots or the video. Test accounts are invented (`alice@example.com`, `bob@example.com`, `sofia@mail.com`), and the screenshots and video use a test account with my own clothes. My personal Gmail appears on purpose as the developer contact on the About screen.
- [x] No course or university credentials anywhere
- [x] Anyone whose data appears in a test was asked first. Only invented test users and my own data appear.

## Keys found and revoked

None. No secret key was ever committed, so nothing needed revoking. The only committed key is the Supabase publishable key, which is public by design, so rotating it would protect nothing.

While doing this check I also fixed:
- **Commit email:** my commits were authored with my personal Gmail. New commits now use my GitHub noreply address.
- **Workflow actions:** they used movable version tags, and are now pinned to commit SHAs.
- **Font licence:** I added the missing `OFL.txt` for the bundled fonts.
