# Security checklist template

Copy this into your workspace `project/SECURITY-CHECKLIST.md` and fill it in
before you make your project repository public.

Every row gets one of **Yes**, **No** or **N/A**, and one line of evidence in
your own words: what you checked, where, and what you found. "N/A" is a correct
answer when it is true, but it needs its reason. A blank row scores nothing, and
a Yes your repository contradicts scores nothing either.

Replace the example evidence with your own.

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | | |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | | |
| 3 | No keystore, `key.properties` or signing credential is in the repository | | |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | | |
| 5 | Any credential that was ever committed has been rotated | | |

## GitHub Actions

If your project has no workflows, mark every row N/A and say so once.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | | |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | | |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | | |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | | |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | | |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | | |
| 12 | Secret scanning and push protection are enabled on the repository | | |

## Backend and security rules

If your app is fully local with no backend, mark every row N/A and say so once.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | | |
| 14 | Rules restrict a user to their own documents where that makes sense | | |
| 15 | If Supabase: Row Level Security is on for every table | | |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | | |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | | |
| 18 | Seed and sample data is invented, not real people's data | | |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | | |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | | |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | | |
| 22 | No classmate's personal data in the repository | | |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | | |
| 24 | Images, fonts and other assets are mine, licensed, or credited | | |
| 25 | Repository visibility is deliberate, and I checked it after my last push | | |

## Anything I found and fixed

Write two or three sentences. What did this checklist catch that you did not
already know about, and what did you change? If it caught nothing, say that. An
honest "nothing, and here is what I checked" is worth more than an invented
finding.
