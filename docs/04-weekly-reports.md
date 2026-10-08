## Week of October 9

### Done this week

- Finished the whole app, frontend and backend. Everything left from last week's list is complete, including frontend polish, a stable Outfit Builder, and data flowing between the Closet, Outfit Builder, Calendar, and View Outfits.
- Completed the Supabase backend: sign up, log in, email verification code, Forgot Password and Set New Password, a "remember me" session, and per-user data for clothing items, outfits, outfit items, calendar entries, and profiles.
- Added photo upload to a private storage bucket, with background removal running in the browser.
- Wrote Row Level Security policies for all five tables and the storage bucket, and tested with two accounts to confirm that account B could not see account A's data.
- Set up GitHub Actions to deploy the web build to GitHub Pages, with the Supabase URL and publishable key stored as repository secrets.
- Scanned the full git history for keys and secrets; no exposed keys or secrets were found.
- Added automated tests covering authentication, Profile, Closet, Outfit Builder, and background-removal behavior.
- Completed final testing and reviewed the application for remaining issues.
- Filmed the demo video.
- Finished the major project documentation and final revisions needed for submission.

### In progress

- Finalizing and organizing the remaining project documents, including the README, Security and Privacy page, weekly reports, and demo video page.
- Making minor documentation and code revisions where needed before submission.

### Blocked or stuck on

- None. The application is complete, tested, and deployed. The remaining work is focused on final documentation and submission preparation.

### Decisions made, and why

- Used only the Supabase publishable key in the app and kept the secret / service_role key out of the repo entirely, because anything compiled into a public web build can be read by anyone.
- Protected data with Row Level Security instead of trusting the app, so the rules still hold even if someone calls the API directly.
- Made the photo bucket private, with one folder per user, so photos cannot be opened through a direct public link.
- Used a separate throwaway account for the demo so no real personal email appears in the public repository.
- Used browser-based background removal instead of a paid external API so the feature does not depend on API credits or a third-party image-processing service.
- Kept the final feature set focused on the core wardrobe experience instead of adding the planned stretch features such as smart outfit recommendations, weather-based suggestions, or automatic outfit generation.

### Hours spent, roughly

Around 30 hours this week (approximately 3–5 hours per day).

### This week I will:

- Submit the completed final project by the October 9 deadline.
- Finalize the reflection based on the weekly reports.
- Make any last-minute documentation corrections required before submission.
