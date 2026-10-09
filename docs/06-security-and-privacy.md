# Security and privacy

This repository is public. This page was filled in honestly and is dated.

**Last checked: 2026-10-05**

## What this app stores

| Data                                                             | Where it lives                                                                    | Who can see it                                                                                          |
| ---------------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Account email and password (password stored only as a hash)      | Supabase Auth                                                                     | Only that user. I can see the email as project owner in the Supabase dashboard; I cannot see passwords. |
| Clothing items (category, color, season, occasion, wear history) | Supabase PostgreSQL                                                               | Only the user who owns the row (Row Level Security)                                                     |
| Saved outfits and Outfit Diary entries                           | Supabase PostgreSQL                                                               | Only the user who owns the row (Row Level Security)                                                     |
| Photos of clothing                                               | Supabase Storage, private bucket                                                  | Only the owner, through short-lived signed URLs                                                         |
| Background-removed images                                        | Created in the browser (U²-Net via ONNX Runtime Web); only the result is uploaded | Same as photos above. The original image is not sent to any third-party AI service.                     |
| UI state (current filters, selected tab)                         | In memory on the device (`setState`)                                              | Only that user, lost on reload                                                                          |

## Secrets

Values my app needs at run time (names only):

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Where they live locally: `lib/services/supabase_config.dart` has this project's public URL and publishable key as defaults, so the app runs with no setup; a git-ignored `env.json` overrides them. `.env.example` is committed with placeholders only.

Where the deploy workflow gets them: repository secrets (Settings > Secrets and variables > Actions). `.github/workflows/deploy-web.yml` reads them as `${{ secrets.SUPABASE_URL }}` and `${{ secrets.SUPABASE_PUBLISHABLE_KEY }}` and passes them to the build with `--dart-define`.

Anything my deployed web build carries that a visitor could read, and why that is acceptable: the web build contains the Supabase project URL and the **publishable** key (`sb_publishable_...`, the successor to the anon key). Both are designed to be public, because they only identify the project and grant the permissions that Row Level Security allows. A visitor who copies the key still cannot read or change another user's rows or photos, because the policies below check `auth.uid()`. The Supabase secret / `service_role` key is not used anywhere in the app, the workflow or the repo, and the app refuses to start if it is given one by mistake. No other secrets exist: background removal runs on the device, and there are no third-party API keys.

## What protects the data on the service side

Supabase Row Level Security is enabled on every table in the `public` schema (checked in the SQL editor: `rowsecurity = true` for all five tables), and the photo bucket is private (`public = false` in `storage.buckets`).

- `clothing_items`, `outfits`, `outfit_items`, `calendar_entries` (the Outfit Diary): separate SELECT, INSERT, UPDATE and DELETE policies, each limited to `(select auth.uid()) = user_id`. INSERT and UPDATE also use `with check` with the same rule.
- `profiles`: SELECT, INSERT and UPDATE limited to `(select auth.uid()) = id`. No DELETE policy, so users cannot delete their profile row directly.
- Storage: the `clothing-images` bucket is private. Policies on `storage.objects` allow SELECT, INSERT, UPDATE and DELETE only where `bucket_id = 'clothing-images'` and the first folder in the file path equals the signed-in user's id.
- Logged-out users match none of these policies, so they can read and write nothing.

How I checked: listed every policy with `select * from pg_policies where schemaname in ('public','storage')`, confirmed RLS is on for each table, and confirmed the bucket is private. Then tested with two accounts on the live app: account B could not see account A's items, outfits, diary entries or photos, and A's data was still there when I logged back in.

## Checklist

- [x] `.env` (and `.env.*`, `env.json`) is in `.gitignore`, and `.env.example` is committed
- [x] `git log -p | grep -i "api_key\|secret\|password\|token"` finds nothing real
- [x] No service account file, keystore or `service_role` key anywhere in the repo
- [x] Security rules or RLS policies written and tested, not left open
- [x] No real personal data in sample data, screenshots or the video
- [x] No course or university credentials anywhere
- [x] Anyone whose data appears in a test was asked first

## Keys found and revoked

None found while doing this check.
