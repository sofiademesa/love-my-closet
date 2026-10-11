# Proposal

## The problem, in one sentence

A person with around 40 clothing pieces struggles to keep track of their wardrobe and decide what to wear, so they keep reaching for the same familiar items while other pieces are overlooked or forgotten.

## Who it is for

People who own around 40 clothing pieces but regularly rely on a smaller selection when choosing what to wear. Today they check their physical closet, rely on memory, or scroll through photos on their phone. Love My Closet puts the whole closet in one place so they can see what they own, build outfits, log what they wear, and bring forgotten pieces back into rotation.

## Core features

All five MVP features from the M7A1 proposal were built, tested and deployed.

- **Home:** the first screen after logging in. It shows a "Wear Me" card with today's Hidden Gem, Wardrobe Stats (total clothing items, saved outfits, and items worn this month), and a More Hidden Gems preview that opens the full list.
- **Digital Closet:** add a clothing item by taking a photo with the camera or choosing one from the gallery, then give it a name, category, occasion and color. The photo's background is removed automatically on the device. Items can be searched, filtered by category, occasion and favorites, marked as favorites, edited and deleted.
- **Outfit Builder:** drag or tap pieces from the Closet onto an outfit board, then move, resize, reorder or remove them. Save the outfit with a name and an optional date.
- **Outfit Diary (Calendar):** a monthly calendar of logged outfits. Add an outfit to a date with the date add bar, write an optional diary note, and tap a date to view or edit it.
- **Hidden Gems:** finds pieces that haven't been worn within the user's chosen threshold (7, 14, 30, 60 or 90 days) and shows them on Home and in the Hidden Gems list.
- **User Profile:** edit display name, email and bio; set the Hidden Gems threshold and a notifications preference; open Accessibility, About, and Help & Support; log out.

Added during development to support these:

- **Accounts:** sign up with email verification, log in, forgot and reset password, and "Remember me".
- **Accessibility:** Text Size, Reduce Motion and High Contrast, applied across the whole app.
- **Onboarding** with a closet-opening animation, plus animations across the app that Reduce Motion turns off.

## Out of scope, and why

- **Smart outfit recommendations, weather-based suggestions, and automatic outfit generation:** each needs its own logic and data (and weather needs an outside API), so I left them out to finish the core features, backend, security and testing properly.
- **Personalized avatar and profile picture:** the profile uses the Love My Closet logo instead. Photo capture belongs in Add Clothes, and an avatar wasn't needed for the app's main purpose.
- **Theme preference (light/dark):** dropped from the profile. High Contrast in Accessibility covers the visibility need.
- **Language / translation:** I started it, but translations didn't work reliably, so I replaced it with Accessibility settings rather than ship a half-working feature.
- **Sending notifications:** the notifications preference is saved, but the app doesn't send reminders yet. That needs a push or email service, which is beyond this scope.
- **Native Android/iOS builds:** the app is built and deployed for the web only (GitHub Pages), which is what the course demo needs.

## Data the app remembers, and where it is saved

Everything is in **Supabase**, and Row Level Security means each user can only reach their own rows and photos.

| Thing | Fields | Where saved |
| --- | --- | --- |
| Account | email, password (hashed) | Supabase Auth |
| Profile | display name, full name, bio, notifications on/off, Hidden Gems threshold | `profiles` table |
| Clothing item | name, category, occasion, color, favorite, photo path, created/updated dates | `clothing_items` table |
| Outfit | name, created/updated dates | `outfits` table |
| Outfit piece | which item, position on the board, size, stacking order | `outfit_items` table |
| Diary entry | outfit, date worn, optional note | `calendar_entries` table |
| Clothing photo | transparent PNG cutout | private `clothing-images` bucket in Supabase Storage, one folder per user |
| Login session | session token | browser storage if "Remember me" is on, otherwise memory only |
| Accessibility settings | text size, reduce motion, high contrast | memory only; they reset when the page reloads |

Last-worn date and times-worn are **not stored**. They're calculated from the diary entries, so they can never disagree with what the user actually logged.

I chose Supabase over `shared_preferences` to learn a cloud backend and so the data follows the account across devices, accepting the extra setup time.

## Risks

- **Hidden Gems logic (from M7A1):** Instead of storing `lastWornDate` and `wearCount`, the app works them out from Calendar entries and compares them with the user's threshold.
- **Supabase integration (from M7A1):** Auth, database, storage and RLS all work. RLS is tested by a two-user SQL test and by trying two accounts on the live app.
- **image_picker on the web:** Gallery selection works in the browser, and a live camera "Take Photo" was added, so the sample-image fallback wasn't needed.
- **Background removal cost:** I didn't use a paid background-removal API. Removal runs in the browser with a U²-Net model (silueta) on ONNX Runtime Web, so there's no API key and no per-photo cost, and the original photo never leaves the device.
- **Turning Figma designs into Flutter:** the closet/cabinet layout and the Outfit Builder drag-and-drop took much longer than planned and cut into time for other screens.
- **CI failing:** checks failed on every commit until automated tests were added on Oct 8.
- **Still open: email delivery.** Supabase's built-in email sender is rate-limited, so confirmation and reset emails can be slow if many are sent at once. A custom SMTP provider would fix this.

## Changes since the last version

- **2026-09-20:** built the design system and onboarding first, so every later screen would share one style. The Figma closet took longer to rebuild in Flutter than planned.
- **2026-09-27:** built the whole frontend in one week, from Home to the Outfit Builder, so the full flow worked before any backend existed. Replaced translation with Accessibility settings because translations were unreliable.
- **2026-09-29:** built the whole backend (Supabase, private photo storage, RLS) in one day. Dropped `season`, `lastWornDate` and `wearCount`; wear stats are now calculated from the diary so they can't go out of sync. Added on-device background removal instead of a paid API.
- **2026-10-03:** added email accounts with verification, password reset and "Remember me", so each user's closet is private and saved.
- **2026-10-06:** dropped the profile picture and theme preference to keep photos in Add Clothes and the profile simple.
- **2026-10-08:** added automated tests, which fixed the CI check that had failed since Week 3.
- **2026-10-09:** ran the security checklist and pinned the GitHub Actions to commit SHAs.
- **2026-10-10:** added a live-camera "Take Photo" option and a date add bar in the Calendar, both through pull requests to keep `main` stable.
