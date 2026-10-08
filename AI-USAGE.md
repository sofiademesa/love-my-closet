# AI Usage Documentation

> **Disclaimer:** This AI usage documentation was compiled and documented late in the project. The entries below are based on my actual AI-assisted work, and the corresponding commit history remains visible in the repository for verification. The commit links are provided to show the changes associated with each AI-assisted task.

## 1. How I used AI

I used AI mainly as a coding assistant during the development of Love My Closet. I asked it to help implement features, structure screens, connect functionality, and refine existing code. I reviewed the generated code, tested it against the design and requirements, and changed or rewrote parts when the output did not match what I wanted.

### 2026-09-20 - Project Setup and Onboarding

- **Tool:** Claude
- **What I asked for:** I asked Claude to help set up the initial Love My Closet Flutter project and implement the onboarding and authentication experience, including the landing page, login, create account, forgot password, and onboarding screens.
- **What it gave back:** Claude generated the initial onboarding and authentication screens, reusable widgets, authentication layouts, onboarding flow, and related Flutter code.
- **What I kept, what I changed, and why:** I used the generated implementation as a starting point, but I did not keep the screens exactly as generated. I compared them with my Figma design and manually changed the layout and visuals, including the cabinet doors and handles on the landing page. I also personally handled parts of the project configuration, including the README, `pubspec.yaml`, `pubspec.lock`, `web/index.html`, fonts, and images. I initially wrote parts of `main.dart` and `theme.dart` and used Claude to help refine and complete them.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a)[https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a](https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a)

### 2026-09-22 - Home Screen

- **Tool:** Claude
- **What I asked for:** I asked Claude to implement the main Home Screen, including the clothing sections, Hidden Gems section, navigation, and reusable UI components.
- **What it gave back:** Claude generated the Home Screen structure, clothing sections, Hidden Gems components, navigation-related code, and reusable components.
- **What I kept, what I changed, and why:** I kept the overall structure because it matched the intended app flow and gave me a working foundation. I later refined the visuals, spacing, colors, and component appearance to better match my design.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/7cc1b3b69d3007c48131d0ac70fd0feca151031c)[https://github.com/sofiademesa/love-my-closet/commit/7cc1b3b69d3007c48131d0ac70fd0feca151031c](https://github.com/sofiademesa/love-my-closet/commit/7cc1b3b69d3007c48131d0ac70fd0feca151031c)

### 2026-09-23 - Palette and Layout Redesign

- **Tool:** Claude
- **What I asked for:** I asked Claude for assistance in refining the existing design. I specifically wanted to reduce the excessive use of pink and decorative elements and make the overall layout more balanced and consistent with my design.
- **What it gave back:** Claude assisted with revising the styling of the Home, Hidden Gems, onboarding, button, and clothing components based on the visual direction I provided.
- **What I kept, what I changed, and why:** I gave Claude specific design directions throughout the refinement. I made a full-screen dot background, then asked for less pink, more neutral tag chips and an Unworn badge, and the removal of decorative section icons because the emojis were rendering with unwanted colors. I also asked to soften the link colors, make the welcome line one color, and reduce the main, secondary, and Skip button heights from 48px to 42px.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/3a5a9a240892fc12eb6f1cceed2924c01fa842fc)[https://github.com/sofiademesa/love-my-closet/commit/3a5a9a240892fc12eb6f1cceed2924c01fa842fc](https://github.com/sofiademesa/love-my-closet/commit/3a5a9a240892fc12eb6f1cceed2924c01fa842fc)

### 2026-09-23 - Closet Feature Implementation and Clothing Card Refinement

- **Tool:** Claude
- **What I asked for:** Implement the Closet flow, including viewing clothes, adding and editing items, uploading photos, viewing item details, searching, filtering, and reusable clothing cards.
- **What it gave back:** Claude generated the main Closet screens, clothing item model, photo picker, search bar, filter chips, dropdown, empty state, and clothing card components. The same clothing card design was also used in areas such as the Home tab and Hidden Gems section.
- **What I kept, what I changed, and why:** I kept the overall Closet workflow and component structure because it covered the functionality I needed, but I identified several problems with the generated clothing card design during review. In the Closet tab, the Edit and Delete actions looked like metadata tags because they used the same rounded-pill treatment as categories such as “Tops” and “Every...”. The “Every...” label was also truncated because of rigid sizing, and the bottom of the card became crowded because multiple pills were stacked together.
  I also found problems with the same card treatment in the Home tab's Hidden Gems section. The “Tops” and “Casual” tags took up too much visual space beside a very small clothing thumbnail, while the image had unused space underneath and the right side became heavily stacked. The “Style This” and “Skip” buttons also felt visually disconnected from the content above them.
  I revised the clothing card layout to create a clearer distinction between actions and metadata, give the clothing image and item name more visual importance, reduce unnecessary stacking, and improve the spacing and hierarchy of the card. I also adjusted the layout so text would not be awkwardly truncated and the card would remain easier to scan.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/2435146a98c1743a9a48943a1894b84be4c7d087)[https://github.com/sofiademesa/love-my-closet/commit/2435146a98c1743a9a48943a1894b84be4c7d087](https://github.com/sofiademesa/love-my-closet/commit/2435146a98c1743a9a48943a1894b84be4c7d087)

### 2026-09-23 - Favorites Feature

- **Tool:** Claude
- **What I asked for:** I asked Claude for assistance in adding a way for users to mark clothing items as favorites and access their saved favorites.
- **What it gave back:** Claude assisted with adding favorite functionality to the clothing tiles and setting up the initial Favorites experience.
- **What I kept, what I changed, and why:** I kept the ability to mark and view favorite clothing items because that was the main functionality I wanted. During testing, I noticed that the initial navigation structure did not fit how I wanted the Closet to work, so I addressed the navigation and organization in the following update.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/38a60e4cfa1c5f6e4f3e9e6c0c6e0e4a6c8e0e0)[https://github.com/sofiademesa/love-my-closet/commit/38a60e493004721141c38360bd2b62d7e5b9fa1e](https://github.com/sofiademesa/love-my-closet/commit/38a60e493004721141c38360bd2b62d7e5b9fa1e)

### 2026-09-24 - Fixing Closet Navigation and Clothing Cards

- **Tool:** Claude
- **What I asked for:** I asked for help refining the Closet navigation and clothing-card layout after testing the previous implementation.
- **What it gave back:** The previous implementation needed adjustments to the way Favorites was organized, and the clothing cards and category navigation needed better spacing and usability.
- **What I kept, what I changed, and why:** I moved Favorites into the Closet category/filter area instead of keeping it as a separate main navigation destination. I also corrected the Closet navigation index and Home navigation mapping, gave the clothing images more space, reorganized the clothing name, heart, tags, and actions, and adjusted the category navigation to make it easier to use with a mouse or trackpad.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/48d372d46c324c2046713551f6e568d2db71ab7c)[https://github.com/sofiademesa/love-my-closet/commit/48d372d46c324c2046713551f6e568d2db71ab7c](https://github.com/sofiademesa/love-my-closet/commit/48d372d46c324c2046713551f6e568d2db71ab7c)

### 2026-09-25 - Outfit Builder

- **Tool:** Claude
- **What I asked for:** I asked Claude to build an Outfit Builder where clothing items could be dragged from the Closet into an outfit area, arranged, and saved as a finished outfit.
- **What it gave back:** Claude created the Outfit Builder, drag-and-drop behavior, save-look sheet, Outfit model, and connections to the Closet and Home screens.
- **What I kept, what I changed, and why:** I kept the drag-and-drop interaction because it matched the intended user experience. I also kept the save flow and used the generated implementation as a foundation, while adjusting navigation and clothing components to fit the rest of my application.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/2b61d7041489935aee2039d14566feaf8e3a1ed6)[https://github.com/sofiademesa/love-my-closet/commit/2b61d7041489935aee2039d14566feaf8e3a1ed6](https://github.com/sofiademesa/love-my-closet/commit/2b61d7041489935aee2039d14566feaf8e3a1ed6)

### 2026-09-25 - Calendar and Shared Outfit Data

- **Tool:** Claude
- **What I asked for:** I asked Claude to add the Calendar based on my mockup and connect it directly to the Outfit Builder. Saved outfits with assigned dates needed to appear on the correct calendar dates and share the same data for adding, editing, deleting, and viewing outfits.
- **What it gave back:** Claude created the Calendar implementation and an `OutfitStore` to act as shared data between the Calendar and Outfit Builder.
- **What I kept, what I changed, and why:** I kept the shared-data approach because it prevented the Calendar and Outfit Builder from maintaining separate copies of outfit information. I also kept the mockup-based Calendar structure and did not use hardcoded sample outfits as the actual application data.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/25a8e1764b435b067f8aca7f459568647d47c794)[https://github.com/sofiademesa/love-my-closet/commit/25a8e1764b435b067f8aca7f459568647d47c794](https://github.com/sofiademesa/love-my-closet/commit/25a8e1764b435b067f8aca7f459568647d47c794)

### 2026-09-25 - Outfit Diary Empty State

- **Tool:** Claude
- **What I asked for:** I asked Claude to improve the empty state for the Outfit Diary and make the action for creating an outfit clearer.
- **What it gave back:** The initial implementation had both a plus icon and a “Log Outfit” button that led to essentially the same action, while the empty state itself was visually plain.
- **What I kept, what I changed, and why:** I removed the redundant action, positioned the remaining action in the lower-right area, added an outfit illustration and supporting message, and adjusted the spacing and padding so the empty state felt intentional rather than unfinished.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/fc5c764003928af801fc5edf2e07a525eee8fc7c)[https://github.com/sofiademesa/love-my-closet/commit/fc5c764003928af801fc5edf2e07a525eee8fc7c](https://github.com/sofiademesa/love-my-closet/commit/fc5c764003928af801fc5edf2e07a525eee8fc7c)

### 2026-09-25 - Closet-Opening Onboarding Animation

- **Tool:** Claude
- **What I asked for:** I asked Claude to make the transition between the first and second onboarding screens feel like opening a physical closet, with the doors opening from the center while the view zooms toward the closet.
- **What it gave back:** Claude combined the closet-door opening animation with a zoom transition.
- **What I kept, what I changed, and why:** I kept the concept and continuous movement because it reinforces the main closet metaphor of the application. I adjusted the implementation as needed so the transition fit the existing onboarding flow.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/865f1b798fa38004eeced786482bcbf9636a29eb

### 2026-09-26 - Profile Screens and Shared User Data

- **Tool:** Claude
- **What I asked for:** Help develop the Profile feature, including editable profile information, Profile navigation, settings rows, and dynamic user information across the app. I wanted the profile to support editing the display name, email, and bio, as well as settings such as notifications and the Hidden Gems threshold.
- **What it gave back:** Claude helped implement the Profile feature through a shared `user_profile_store.dart`, `edit_profile_screen.dart`, `profile_screen.dart`, and reusable `profile_menu_row.dart`. The shared store became the single source of truth for the display name, email, bio, notifications setting, and Hidden Gems threshold. The Profile screen included the avatar, `"{Name}'s Closet"` title, bio, Edit Profile, Language, Hidden Gems Threshold, Notifications, About, Help & Support, and Log Out. It also connected the Profile icon across the Home, Closet, Calendar, and Outfit Builder screens.
- **What I kept, what I changed, and why:** I kept the shared-store approach because the same user information needed to be displayed and updated across multiple screens. I also kept the listener-based approach so Home and Closet could update immediately when the user changed their display name. I reviewed the generated implementation against my intended Profile design and made sure the screens and navigation matched the rest of the application. I also specifically addressed the existing “always Sofia” problem by making sign-up save the name and email entered by the user instead of using a fixed name. The Profile structure and design were based on what I had already established, while Claude assisted with implementing the supporting functionality.
- **Commit:** [ 4f9072a](https://github.com/sofiademesa/love-my-closet/commit/4f9072aaaf508028da131f196495bb537b6b895f)

### 2026-09-26 - Profile Page and Dynamic User Name

- **Tool:** Claude
- **What I asked for:** Implement the Profile page exactly as shown in the mockup. The user should be able to enter their name, and the entered name should dynamically appear on the Profile page instead of the fixed “Sofia” name. Also, use the same user name dynamically in the greeting on the Home page.
- **What it gave back:** Claude generated the Profile and Edit Profile screens, a shared user profile store, profile menu components, and the logic needed to update and display the user's name. It also connected the profile name to the Home page greeting so that changing the name in Edit Profile updates the displayed name across the app.
- **What I kept, what I changed, and why:** I kept the Profile page structure and the shared profile-store approach because it allowed the user's display name to be updated in one place and reflected across different screens. I also kept the Edit Profile form so the user could enter and save their name. I reviewed the implementation against the mockup and the intended app flow and used the dynamic name behavior so the Profile page and Home greeting would no longer rely on a fixed “Sofia” value.
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/4f9072aaaf508028da131f196495bb537b6b895f](https://github.com/sofiademesa/love-my-closet/commit/4f9072aaaf508028da131f196495bb537b6b895f)
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/21c2f46c571d64b3438f5a90d850afe6a336a9b9](https://github.com/sofiademesa/love-my-closet/commit/21c2f46c571d64b3438f5a90d850afe6a336a9b9)

### 2026-09-26 - Help and Support Page

- **Tool:** Claude
- **What I asked for:** I provided the actual Help & Support content and asked Claude to structure it within my existing screen without creating a separate page or unnecessary expandable sections. I also wanted support email addresses to be clickable.
- **What it gave back:** Claude implemented the content structure and clickable support links within the existing design.
- **What I kept, what I changed, and why:** I wrote the actual content myself, including the Getting Started, Managing Closet, Planning Outfits, Having an Issue, and Need More Help sections. I kept the content and design decisions and used Claude mainly to translate the content into the Flutter UI.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/f59f94a169bf1681e94ef3db928fcf7da6653b70)[https://github.com/sofiademesa/love-my-closet/commit/f59f94a169bf1681e94ef3db928fcf7da6653b70](https://github.com/sofiademesa/love-my-closet/commit/f59f94a169bf1681e94ef3db928fcf7da6653b70)

### 2026-09-26 - About Love My Closet Page

- **Tool:** Claude
- **What I asked for:** I provided the complete content for the About page and asked Claude to implement it using the existing design, including clickable email and LinkedIn links.
- **What it gave back:** Claude structured the supplied content into the Flutter page and implemented the interactive links.
- **What I kept, what I changed, and why:** I wrote the actual content myself, including the app description, idea, features, “Made to Be Loved Again” section, developer introduction, and contact information. I kept my content and design decisions and used Claude to help implement the page.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/7aba06a18fa145c5c3b175558d57f194f0c034cc)[https://github.com/sofiademesa/love-my-closet/commit/7aba06a18fa145c5c3b175558d57f194f0c034cc](https://github.com/sofiademesa/love-my-closet/commit/7aba06a18fa145c5c3b175558d57f194f0c034cc)

### 2026-09-26 - Accessibility Settings

- **Tool:** Claude
- **What I asked:** I asked Claude to replace the Language option in the Profile page with Accessibility and add three settings:
  - Text Size: Small / Default / Large
  - Reduce Motion: On / Off
  - High Contrast: On / Off
- I specifically asked that these settings be functional across the entire app. For example, if the user selects a larger text size, it should apply to all screens rather than only the Accessibility page. I also wanted the existing UI design to remain unchanged unless an accessibility setting was enabled.
- **What Claude generated:** Claude implemented an Accessibility screen and shared accessibility settings so changes could be applied throughout the app. It also implemented text scaling, reduced animation behavior, and high-contrast styling.
- **What I kept/changed and why:** I kept the three-setting approach and the shared accessibility functionality because the settings needed to affect the whole application. I tested the High Contrast option and found that Claude's first implementation changed the colors too aggressively, making the existing pink palette appear overly bright/neon and uncomfortable to look at. Instead of applying a broad color filter, I asked Claude to revise the implementation using specific, calmer darker shades for text and accent colors while preserving the existing backgrounds and overall UI design. I also made sure that turning the setting off returns the app to its original appearance.
- **What I learned/understood:** The accessibility settings use shared state so that one change can affect multiple screens consistently. Text-size changes need to be applied globally, while reduced motion should affect animations without redesigning the interface. High contrast should improve readability without unnecessarily changing the app's visual identity.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/e163012452ff9cc644e9e2885bcd399fd853285f?utm_source=chatgpt.com)[**https://github.com/sofiademesa/love-my-closet/commit/e163012452ff9cc644e9e2885bcd399fd853285f**](https://github.com/sofiademesa/love-my-closet/commit/e163012452ff9cc644e9e2885bcd399fd853285f)

### 2026-09-26 - Bottom Navigation Bar UI Redesign

- **Tool:** Claude
- **What I asked:** The bottom navigation bar had already been implemented earlier with the main screens of the app. I later decided to redesign its visual presentation so it would better match the overall Love My Closet interface and make the active section clearer.
- **What Claude generated:** The earlier Claude-generated navigation used a simpler icon-based layout. The five main sections were represented by icons, with the selected item indicated through a smaller visual highlight. The navigation was already functional and connected to the main screens.
- **What I kept/changed and why:** I kept the existing navigation structure and functionality rather than rebuilding it. I only changed its UI and visual behavior.
  I redesigned it into a floating pill-style navigation bar. The selected section now expands into a pink pill containing both its icon and text label, while the other sections remain as icons. For example, when the user is on Closet, the Closet item expands to show the hanger icon together with the “Closet” label.
  I made this change because the original icon-only presentation did not make the user's current location as immediately clear. The new active-state treatment gives the selected section a stronger visual indication while keeping the same five-section navigation and overall app structure.
  The redesign also retained the existing navigation destinations: Home, Closet, Style, Diary, and Profile. The commit shows that the changes were focused on `bottom_nav_bar.dart` and related navigation styling in `theme.dart`, rather than introducing a new navigation system.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f?utm_source=chatgpt.com)[https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f](https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f)

### 2026-09-27 - Hidden Gems and Bottom Navigation Refinements

- **Tool:** Claude
- **What I asked for:** I asked for help improving the Hidden Gems presentation and making the bottom navigation work better across different screen sizes and accessibility font sizes.
- **What it gave back:** Claude-assisted changes were made to the Hidden Gems components and navigation.
- **What I kept, what I changed, and why:** I increased the Hidden Gems thumbnail from 56px to 96px, moved it above the text, and changed the “Wear Again” action into a full-width 48px button with an icon. I also expanded the Hidden Gems sheet from 2 to 6 items and increased its height from 55% to 75%. For the bottom navigation, an earlier AI suggestion shortened “Outfit Builder” to “Builder.” I rejected that because the full feature name was clearer. Instead, I kept “Outfit Builder,” wrapped each navigation item in `Flexible`, and used one-line text with ellipsis so the navigation could adapt to accessibility font sizes and smaller screens.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/723fdaa8947ac36aaf8fca7db7bf7e6d60ff0f66)[https://github.com/sofiademesa/love-my-closet/commit/723fdaa8947ac36aaf8fca7db7bf7e6d60ff0f66](https://github.com/sofiademesa/love-my-closet/commit/723fdaa8947ac36aaf8fca7db7bf7e6d60ff0f66)

### 2026-09-28 - App-Wide Animation System

- **Tool:** Claude
- **What I asked for:** I asked Claude to add animations throughout Love My Closet while keeping the Reduce Animations accessibility setting functional. I wanted the animations to feel polished and responsive without introducing unnecessary delays.
- **What it gave back:** Claude created a reusable animation toolkit in `lib/animations/app_motion.dart` and applied it to screen transitions, staggered Closet/outfit/Hidden Gems/Home animations, Outfit Builder pop-ins, press feedback, crossfades, heart animations, deletion feedback, Calendar animations, dialogs, sheets, and loading indicators.
- **What I kept, what I changed, and why:** I kept the centralized animation toolkit because it made the motion behavior more consistent across the application. I specifically did not keep artificial loading animations because the app did not have network or asynchronous operations that required a loading delay. Claude could not compile and run the Flutter application in its environment because the Flutter SDK was unavailable, so I treated the generated code as something that still required local testing.
- **Commit:** [ ](https://github.com/sofiademesa/love-my-closet/commit/10e79997ac9986416592746907d7254148d5a273)[https://github.com/sofiademesa/love-my-closet/commit/10e79997ac9986416592746907d7254148d5a273](https://github.com/sofiademesa/love-my-closet/commit/10e79997ac9986416592746907d7254148d5a273)
