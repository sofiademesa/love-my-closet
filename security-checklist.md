# Security checklist

Love My Closet (Flutter web + Supabase). Checked 2026-10-09 against the files in
the repository, its full git history, the latest Actions run, GitHub settings
and a signed-out test against the live Supabase project.

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | No | `supabase_config.dart` has the project URL and publishable key as defaults, on purpose, so the app runs with no setup. This is safe because the publishable key is not a secret: Supabase designs it to live in client apps, and every web build has to carry it, so the live site already shows it to anyone even when it comes from `env.json`. It only gives signed-out access, which RLS blocks (row 17). The key that would be dangerous, `service_role`, bypasses RLS and is never in `lib/`; the app refuses to start if given one. Other `password`/`token` matches are variable names. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | Yes | `.gitignore` covers `.env`, `.env.*` and `env.json`; `.env.example` is committed with placeholders only; local runs use `--dart-define-from-file=env.json` and CI passes `--dart-define`. The app throws on startup if given an `sb_secret_` or `service_role` key. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | No `android/` or `ios/` folder exists (web-only build); a file search finds no `.jks`, `.keystore`, `key.properties` or service-account JSON, and `*.jks`/`*.keystore` are gitignored anyway. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | Ran `git log -p --all \| Select-String -Pattern "api_key\|secret\|password\|token\|sb_publishable\|sb_secret"` in PowerShell on 2026-10-09. The only real key found was the public Supabase publishable key in `supabase_config.dart` (see row 1). Every other match was a template placeholder (`put_your_key_here`, `sb_publishable_...`), a fake test value (`secret123`, `password123`), a variable name, a `${{ secrets.… }}` reference or documentation. No secret or `service_role` key in any commit. |
| 5 | Any credential that was ever committed has been rotated | N/A | The row 4 search of the full history found no secret or `service_role` key ever committed. The only committed credential is the Supabase publishable key, which is public by design and ships in every web build, so rotating it would protect nothing. |

## GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | Read `.github/workflows/deploy-web.yml` (the only workflow): the Supabase values come only from `${{ secrets.… }}`; no literal URL or key. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | Yes | The build step reads `${{ secrets.SUPABASE_URL }}` and `${{ secrets.SUPABASE_PUBLISHABLE_KEY }}` into env vars and passes them to `flutter build web` with `--dart-define`. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | Yes | The only `echo` lines in `deploy-web.yml` write `ready=true/false` and notices. Opened run #69 (2026-10-09), build job → Build web step: `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` show as `***`, and the command only references `$SUPABASE_URL` / `$SUPABASE_PUBLISHABLE_KEY`, so no value is printed. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The workflow only builds Flutter web for GitHub Pages; there is no Android build or keystore. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The only artifact is `build/web` via `upload-pages-artifact`. It contains the compiled publishable key and URL (meant to be public); no `env.json`, `.env`, keystore or other key file is copied in. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | Yes | All four actions in `deploy-web.yml` are pinned to full commit SHAs with the version kept as a comment, e.g. `subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2 # v2`. Pinned in commit `2d42ee8`; the next run (#70, 2026-10-09) built and deployed successfully. |
| 12 | Secret scanning and push protection are enabled on the repository | Yes | Checked Settings → Advanced Security on 2026-10-09: Secret Protection and Push protection both show a "Disable" button, meaning both are enabled. |

## Backend and security rules

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | Yes | Supabase, not Firebase. Every table policy and all four `storage.objects` policies in `supabase/migrations/20260929000000_love_my_closet_schema.sql` are `to authenticated`, and `anon` has all table privileges revoked. The `clothing-images` bucket is private (`public = false`). |
| 14 | Rules restrict a user to their own documents where that makes sense | Yes | Select/insert/update/delete policies check `(select auth.uid()) = user_id` (or `= id` on `profiles`); storage checks the first path folder equals the user's id; composite foreign keys stop linking to another user's items. `supabase/tests/rls_isolation_test.sql` tests this with two users. |
| 15 | If Supabase: Row Level Security is on for every table | Yes | The migration runs `enable row level security` on all five tables (`profiles`, `clothing_items`, `outfits`, `outfit_items`, `calendar_entries`); `docs/06` records `rowsecurity = true` for all five in the live project. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The app uses no Firebase or Google API keys; background removal runs on-device with ONNX Runtime Web. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | Yes | On 2026-10-09, signed out, I used only the public publishable key from PowerShell: reading `/rest/v1/clothing_items` and inserting a fake item both returned 401 Unauthorized. As a control, `/auth/v1/settings` with the same key succeeded, so the key is valid and the 401s come from RLS and the revoked `anon` grants. Anonymous sign-ins are off (`anonymous_users=False`). The two-account test on the live app is recorded in `docs/06`. |
| 18 | Seed and sample data is invented, not real people's data | Yes | There is no seed file. Test data is `alice@example.com` / `bob@example.com` in the RLS test and "Sofia" / `sofia@mail.com` in `test/auth_test.dart`. Never sent anywhere, but `mail.com` is a real provider, so `example.com` would be safer. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | Client side: `Validators` in `auth_layout.dart` and form `validator:`s (email format, 8-character passwords, required name). Server side the database enforces it anyway: `check` constraints on name length (1–80), allowed category/occasion/color values, note ≤ 2000, bio ≤ 300, scale 0.4–3.0, plus a bucket limit of PNG only, 10 MB max. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | The web build contains only the project URL and publishable key, both meant to be public. No secret key, no third-party API key (background removal is local), and `debugPrint` logs only the URL, never a key or session. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | No | No student number, phone or address; commit titles are clean (`git log --all --format="%s"`). My personal Gmail appears on purpose as the developer contact in `about_screen.dart`, and as the author email on past commits (`git log --all --format="%ae"`). Since 2026-10-09 new commits use my GitHub noreply address; old commits were not rewritten so the commit links in AI-USAGE.md keep working. |
| 22 | No classmate's personal data in the repository | Yes | Searched every `.dart`, `.md` and `.sql` file for emails and names: the only real person named is me; the test users are invented. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | All 95 hosted packages in `pubspec.lock` resolve to `https://pub.dev` (the other 5 are the Flutter SDK); `build/` and `.dart_tool/` are in `.gitignore`. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | Icons and the heart avatar in `assets/images/` are my own Figma designs. Young Serif and DM Sans are credited as SIL OFL in the README, and on 2026-10-09 I added `assets/fonts/OFL.txt` with both fonts' copyright lines and the full licence text, as the OFL requires. The ONNX Runtime and `silueta` model licences are in `web/bg_removal/THIRD_PARTY_NOTICES.md`. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | The repo is public on purpose, for academic evaluation and portfolio (as the README says), and GitHub Pages needs a public repo on a free account. Checked Settings → General → Danger Zone on 2026-10-09 after my last push: the repository is public. |

## Anything I found and fixed

The checklist revealed two issues I was not aware of: all previous commits were
authored with my personal Gmail address, and the deployment workflow referenced
its actions by movable version tags. To address these, I configured Git to use my
GitHub noreply address with email privacy enabled, pinned all four actions to full
commit SHAs (verified by a successful run, #70), and added the missing `OFL.txt`
licence for the bundled fonts. The publishable key in `supabase_config.dart`
(row 1) was an intentional choice that keeps the app runnable without setup;
however, the checklist showed that my documentation incorrectly stated "no keys in
source", so I revised it to match the code.
