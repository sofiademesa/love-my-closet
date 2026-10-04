## Week 3 

### Done this week
- Finished the whole app, frontend and backend. Everything left from last week's list is done: the frontend polish, a stable Outfit Builder, and data flowing between the Closet, Outfit Builder, Calendar and View Outfits.
- Completed the Supabase backend: sign up, log in, email verification code, Forgot Password and Set New Password, a "remember me" session, and per-user data for clothing items, outfits, outfit items, calendar entries and profiles.
- Added photo upload to a private storage bucket, with background removal running in the browser.
- Wrote Row Level Security policies for all five tables and the storage bucket, and tested with two accounts: account B could not see account A's data.
- Set up GitHub Actions to deploy the web build to GitHub Pages, with the Supabase URL and publishable key stored as repository secrets.
- Scanned the full git history for keys and secrets (nothing found).
- Filmed the demo video.

### In progress
- Finishing and correcting the project documents (README, Security and privacy page, weekly reports, demo video page).
- Making slight revisions to the code.
- Doing a final security check and final testing before submission.

### Blocked or stuck on

### Decisions made, and why
- Used only the Supabase publishable key in the app and kept the secret / service_role key out of the repo entirely, because anything compiled into a public web build can be read by anyone.
- Protected data with Row Level Security instead of trusting the app, so the rules still hold even if someone calls the API directly.
- Made the photo bucket private, with one folder per user, so photos can't be opened by a direct link.
- Used a separate throwaway account for the demo so no real personal email appears in a public repo.

### Hours spent, roughly
[Fill in your number.]

### Next week I will:
- Submit the final project on Wednesday, October 7 and present it in class.
- Write the final reflection from these weekly reports.
