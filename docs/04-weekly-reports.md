# Weekly reports

One entry per week, newest at the top, written during that week. Five minutes each. They are the record of how the project actually went, and they make your final reflection almost write itself.

## Week 4 (Oct 5 to Oct 11)

**Done this week**
- Rewrote the README with new screenshots and sections (several revision passes)
- Updated the design system, weekly reports, security and privacy, mockup, and demo video docs
- Revised the proposal with detailed feature descriptions
- Added widget tests and merged them through PR #1; CI checks now pass 2/2
- Improved outfit clearing feedback and made color selection accessible
- Fixed clothing tile text overflow and removed the profile camera
- Added a favicon
- Added a "Take Photo" option to Add Clothes (PR #2)
- Replaced the calendar "+" button with a date add bar (PR #3)
- Created the security checklist and updated it with findings
- Pinned GitHub workflow actions to commit SHAs
- Added the OFL licence for the bundled fonts and fixed a pubspec comment
- Documented AI usage in detail in AI-USAGE.md
- Deleted START-HERE.md

**In progress**
- Finalizing the demo video and its markdown write-up
- Final polish on the README and docs before submission

**Blocked or stuck on**
- CI was failing (1/2 checks) on every commit until Oct 6. Adding proper tests on Oct 8 fixed it.
- A few doc-only upload commits still show 0/2 checks and need a look

**Decisions made, and why**
- Switched to feature branches and pull requests (add-tests, add-take-photo, calendar-add-bar) so main stays stable and every change is reviewable
- Pinned workflow actions to commit SHAs so a compromised or changed action tag can't silently alter the pipeline
- Bundled the fonts with their OFL licence so the app doesn't depend on fetching fonts at runtime and stays licence-compliant
- Replaced the calendar "+" button with a date add bar because it is clearer and quicker for adding outfits to a date
- Removed the profile camera to keep the profile screen simpler and keep photo capture in Add Clothes

**Hours spent, roughly:** 20

**Next week I will:**
- Finish and submit the demo video
- Fix the remaining failing checks on doc commits
- Do a full app test pass on a real device
- Write the final reflection

## Week 3 (Sep 28 to Oct 4)

**Done this week**
- Integrated Supabase for authentication, data storage, and persistence
- Built email authentication and connected it to the Login and Signup screens
- Added an eye icon to toggle password visibility
- Finished the background removal integration for clothing photos
- Stabilized the Outfit Builder's drag-and-drop interactions
- Fixed Outfit Builder overflow and changed the clothes background color dot
- Enhanced the color dropdown with swatches and selection styling
- Added animations across the app
- Built the avatar feature
- Created AI-USAGE.md and started the demo video doc

**In progress**
- Verifying user-specific data access for clothing items, outfits, and profiles
- Testing CRUD operations for clothing items and saved outfits
- AI usage documentation

**Blocked or stuck on**
- CI checks failing (1/2) on every commit. Need to find which check fails and why.
- Outfit Builder layout overflowing on smaller screens (fixed Oct 4)

**Decisions made, and why**
- Chose Supabase for auth and storage because it gives email auth, a database, and file storage out of the box without running my own server
- Used color swatches instead of plain text options so users can pick colors visually
- Added animations to make screen transitions and interactions feel smoother and more polished

**Hours spent, roughly:** 15

**Next week I will:**
- Fix the failing CI check by adding tests
- Rewrite the README with screenshots
- Update the design system, security, and mockup docs
- Improve accessibility of color selection
- Test security rules and session persistence
- Start recording the demo video

## Week 2 (Sep 21 to Sep 27)

**Done this week**
- Built the Home screen: Hidden Gem of the Day card, Wardrobe Stats (total items, outfits, items worn this month), and the More Hidden Gems section
- Built the Hidden Gems list screen and redesigned it
- Built the Closet screen: search, category and occasion filter chips, clothing item grid, and empty state
- Centered the Closet empty state, pinned filters above the scrolling grid, and redesigned the Closet icons
- Built the Add Clothes flow: camera and gallery photo selection, background removal, and name, category, occasion, and color fields
- Built the Edit Item screen: editing details, replacing photos, and saving or deleting items
- Built the Outfit Builder: draggable outfit board, Save This Look modal, and View Outfits list
- Built the Calendar screen for viewing saved outfits by date
- Built the Profile screen and its sub-screens: Edit Profile, Accessibility, Hidden Gems Threshold, Notifications, About Love My Closet, Help & Support, and the logout confirmation dialog
- Replaced the language and translation feature with Accessibility settings (text size, reduced motion, high contrast)

**In progress**
- Connecting data between screens so Closet items appear in the Outfit Builder and saved outfits appear in the Calendar and View Outfits
- Stabilizing the Outfit Builder's drag-and-drop

**Blocked or stuck on**
- The Outfit Builder's drag-and-drop was the hardest part of the frontend and took much more work than a static layout
- Sharing data between screens instead of each screen working on its own
- Translations weren't working reliably; some text didn't translate
- Some Figma designs didn't translate well into Flutter and had to be adjusted or redesigned

**Decisions made, and why**
- Replaced the language and translation feature with Accessibility settings because translations were unreliable, and a working accessibility feature is more useful than a half-working translation one
- Finished the whole frontend before backend integration so the main user flow was in place first
- Pinned the Closet filters above the grid so they stay reachable while scrolling through a large closet

**Hours spent, roughly:** 20

**Next week I will:**
- Integrate Supabase for authentication, data storage, and persistence
- Connect Login and Signup to authentication
- Complete photo storage and background-removal integration
- Stabilize the Outfit Builder's drag-and-drop
- Complete data flow between the Closet, Outfit Builder, Calendar, and View Outfits

## Week 1 (Sep 15 to Sep 20)

**Done this week**
- Started implementing the Love My Closet design system in Flutter
- Added and organized fonts, images, and other assets
- Started building reusable components and UI patterns from the design phase
- Set up initial screen layouts based on the approved mockups
- Built the onboarding screens, the first completed part of the app

**In progress**
- Closet/cabinet layout
- Reusable components for the remaining screens

**Blocked or stuck on**
- Translating the Figma closet/cabinet design into Flutter. It was made of simple shapes in Figma, but rebuilding it with Flutter widgets took much longer than expected and cut into time for other screens.

**Decisions made, and why**
- Built the onboarding screens first to establish the initial user flow and give the rest of the interface a foundation
- Set up the design system, assets, and reusable components before building screens so every screen would share the same visual style

**Hours spent, roughly:** 12

**Next week I will:**
- Build the Home, Closet, Outfit Builder, Calendar, and Profile screens
- Build the Add Clothes and Edit Item flows
- Connect the onboarding flow to the main app
- Start connecting data between screens
