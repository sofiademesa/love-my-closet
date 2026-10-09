# AI Usage Documentation

> **Disclaimer:** This AI usage documentation was compiled and documented late in the project. The entries below are based on my actual AI-assisted work, and the corresponding commit history remains visible in the repository for verification. The commit links are provided to show the changes associated with each AI-assisted task.

## 1. How I used AI

I used AI extensively to work more efficiently, develop features, troubleshoot issues, and learn throughout the development of Love My Closet. However, I did not blindly accept its output. I reviewed, tested, and revised the generated code based on my designs, requirements, and own judgment.

### 2026-09-20 - Project Setup and Onboarding

- **Tool:** Claude
- **What I asked for:** I asked Claude to help set up the initial Love My Closet Flutter project and implement the onboarding and authentication experience, including the landing page, login, create account, forgot password, and onboarding screens.
- **What it gave back:** Claude generated the initial onboarding and authentication screens, reusable widgets, authentication layouts, onboarding flow, and related Flutter code.
- **What I kept, what I changed, and why:** I used the generated implementation as a starting point, but I did not keep the screens exactly as generated. I compared them with my Figma design and manually changed the layout and visuals, including the cabinet doors and handles on the landing page. I also personally handled parts of the project configuration, including the README, `pubspec.yaml`, `pubspec.lock`, `web/index.html`, fonts, and images. I initially wrote parts of `main.dart` and `theme.dart` and used Claude to help refine and complete them.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a

### 2026-09-22 - Home Screen

- **Tool:** Claude
- **What I asked for:** I asked Claude to implement the main Home Screen, including the clothing sections, Hidden Gems section, navigation, and reusable UI components.
- **What it gave back:** Claude generated the Home Screen structure, clothing sections, Hidden Gems components, navigation-related code, and reusable components.
- **What I kept, what I changed, and why:** I kept the overall structure because it matched the intended app flow and gave me a working foundation. I later refined the visuals, spacing, colors, and component appearance to better match my design.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/7cc1b3b69d3007c48131d0ac70fd0feca151031c

### 2026-09-23 - Closet Feature Implementation and Clothing Card Refinement

- **Tool:** Claude
- **What I asked for:** Implement the Closet flow, including viewing clothes, adding and editing items, uploading photos, viewing item details, searching, filtering, and reusable clothing cards.
- **What it gave back:** Claude generated the main Closet screens, clothing item model, photo picker, search bar, filter chips, dropdown, empty state, and clothing card components. The same clothing card design was also used in areas such as the Home tab and Hidden Gems section.
- **What I kept, what I changed, and why:** I kept the overall Closet workflow and component structure because it covered the functionality I needed, but I identified several problems with the generated clothing card design during review. In the Closet tab, the Edit and Delete actions looked like metadata tags because they used the same rounded-pill treatment as categories. I also found problems with the same card treatment in the Home tab's Hidden Gems section. The “Tops” and “Casual” tags took up too much visual space beside a very small clothing thumbnail, while the image had unused space underneath and the right side became heavily stacked. The “Style This” button also felt visually disconnected from the content above them. Afterwards, I revised the clothing card layout to create a clearer distinction between actions and metadata, give the clothing image and item name more visual importance, reduce unnecessary stacking, and improve the spacing and hierarchy of the card. I also adjusted the layout so text would not be awkwardly truncated and the card would remain easier to scan.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/2435146a98c1743a9a48943a1894b84be4c7d087

### 2026-09-25 - Outfit Builder

- **Tool:** Claude
- **What I asked for:** I asked Claude to build an Outfit Builder where clothing items could be dragged from the Closet into an outfit area, arranged, and saved as a finished outfit.
- **What it gave back:** Claude created the Outfit Builder, drag-and-drop behavior, save-look sheet, Outfit model, and connections to the Closet and Home screens.
- **What I kept, what I changed, and why:** I kept the drag-and-drop interaction because it matched the intended user experience. I also kept the save flow and used the generated implementation as a foundation, while adjusting navigation and clothing components to fit the rest of my application.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/2b61d7041489935aee2039d14566feaf8e3a1ed6

### 2026-09-25 - Calendar and Shared Outfit Data

- **Tool:** Claude
- **What I asked for:** I asked Claude to add the Calendar based on my mockup and connect it directly to the Outfit Builder. Saved outfits with assigned dates needed to appear on the correct calendar dates and share the same data for adding, editing, deleting, and viewing outfits.
- **What it gave back:** Claude created the Calendar implementation and an `OutfitStore` to act as shared data between the Calendar and Outfit Builder.
- **What I kept, what I changed, and why:** I kept the shared-data approach because it prevented the Calendar and Outfit Builder from maintaining separate copies of outfit information. I also kept the mockup-based Calendar structure and did not use hardcoded sample outfits as the actual application data.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/25a8e1764b435b067f8aca7f459568647d47c794

### 2026-09-25 - Closet-Opening Onboarding Animation

- **Tool:** Claude
- **What I asked for:** I asked Claude to make the transition between the first and second onboarding screens feel like opening a physical closet, with the doors opening from the center while the view zooms toward the closet.
- **What it gave back:** Claude combined the closet-door opening animation with a zoom transition.
- **What I kept, what I changed, and why:** I kept the concept and continuous movement because it reinforces the main closet metaphor of the application. I adjusted the implementation as needed so the transition fit the existing onboarding flow.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/865f1b798fa38004eeced786482bcbf9636a29eb

### 2026-09-26 - Profile Page and Dynamic User Name

- **Tool:** Claude
- **What I asked for:** Help implement the Profile page based on my mockup, including an Edit Profile screen where users could enter and update their display name. I also wanted the Home page greeting to use the user's entered name instead of displaying the fixed name “Sofia.”
- **What it gave back:** Claude assisted with implementing the Profile and Edit Profile screens, the shared profile store, and the logic for updating and displaying the user's name. It also helped connect the profile data to the Home page greeting so that the displayed name could stay consistent across both screens.
- **What I kept, what I changed, and why:** I kept the Profile and Edit Profile screen structure and the shared profile-store approach because they allowed the user's name to be managed in one place and displayed across multiple screens. I reviewed the implementation against my mockup and the intended app flow. I also worked on the dynamic user-name functionality to ensure the Profile page and Home greeting used the user's information instead of a hardcoded “Sofia” value. Claude assisted with implementing the feature, while I reviewed the changes and worked on how the functionality fit into the existing application.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/4f9072aaaf508028da131f196495bb537b6b895f
- **Related Commit:** https://github.com/sofiademesa/love-my-closet/commit/21c2f46c571d64b3438f5a90d850afe6a336a9b9

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
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/e163012452ff9cc644e9e2885bcd399fd853285f

### 2026-09-28 - App-Wide Animation System

- **Tool:** Claude
- **What I asked for:** I asked Claude to add animations throughout Love My Closet while keeping the Reduce Animations accessibility setting functional. I wanted the animations to feel polished and responsive without introducing unnecessary delays.
- **What it gave back:** Claude created a reusable animation toolkit in `lib/animations/app_motion.dart` and applied it to screen transitions, staggered Closet/outfit/Hidden Gems/Home animations, Outfit Builder pop-ins, press feedback, crossfades, heart animations, deletion feedback, Calendar animations, dialogs, sheets, and loading indicators.
- **What I kept, what I changed, and why:** I kept the centralized animation toolkit because it made the motion behavior more consistent across the application. I specifically did not keep artificial loading animations because the app did not have network or asynchronous operations that required a loading delay. Claude could not compile and run the Flutter application in its environment because the Flutter SDK was unavailable, so I treated the generated code as something that still required local testing.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/10e79997ac9986416592746907d7254148d5a273

### 2026-09-29 - Add Clothes Photo Background Removal Flow

- **Tool:** Claude
- **What I asked for:** I asked Claude to implement only the Add Clothes photo flow in my existing Love My Closet Flutter project. I specifically asked it to inspect and reuse the existing screen, theme, widgets, navigation, and dependencies rather than redesigning the UI. The requested flow was Take Photo/Choose from Gallery → Select Image → Remove Background → Transparent Preview → Undo/Use Photo. I also required the background-removal solution to be genuinely free, preferably on-device and open-source, with no API key or paid service.
- **What it gave back:** Claude assisted with implementing the photo-selection flow, background-removal processing, loading and error states, transparent preview, checkerboard transparency preview, background-color preview options, Undo, and Use Photo behavior. The first approach used a paid external background-removal API, which did not meet my requirements. After I rejected that approach, Claude assisted with adapting the implementation to the existing on-device web background-removal setup using a local ONNX model and ONNX Runtime Web. During testing, there was also an issue where the model was not being served from the correct `web/bg_removal/models/` location, so Claude assisted with correcting the model path and improving the error handling.
- **What I kept, what I changed, and why:** I kept the overall photo-flow structure and the parts that integrated well with the existing Love My Closet UI. I rejected the initial paid API approach because I specifically wanted a free solution without API costs or paid usage. I kept the on-device ONNX approach because it allowed the background removal to run within the project instead of depending on an external paid service. I also kept the checkerboard preview and Undo/Use Photo actions because they gave the user a clearer way to review the processed image before deciding to use it. I reviewed the implementation during testing and corrected the model-path issue rather than treating the generated code as automatically functional.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/7f38864e556397361a7469e8278bd3fe20af4b8b

### 2026-09-29 - Supabase Integration and Data Persistence

- **Tool:** Claude
- **What I asked for:** I asked Claude to help integrate Supabase into my existing Love My Closet Flutter application so that authentication and application data, including clothing items and outfits, could be stored and retrieved through the backend. I wanted to connect the existing features to persistent storage without unnecessarily restructuring the project.
- **What it gave back:** Claude assisted with the Flutter-side implementation, including connecting existing stores, models, screens, and data operations to Supabase-backed functionality. This helped the application work with persistent backend data instead of relying only on temporary in-memory state.
- **What I kept, what I changed, and why:** I kept the parts that fit my existing application structure and reviewed the generated implementation before integrating it. My role was not limited to asking Claude to connect Supabase: I personally configured the Supabase project, environment variables, database schema, table relationships, and RLS policies, and I tested the setup through both the application and the Supabase dashboard. Claude assisted with the application-side integration, while I handled the database configuration and made decisions about how user data should be organized and protected. I kept this approach because it allowed me to use AI as a coding assistant while still understanding and taking responsibility for the backend setup. 
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/591c9aafd44327452b8b65727e31326610a963a5

### 2026-09-29 - Outfit Builder Improvements

- **Tool:** Claude
- **What I asked for:** I asked Claude to improve the existing Outfit Builder based on issues I noticed while testing it. I specifically wanted the existing UI and overall design to remain intact instead of creating a completely new Outfit Builder. The requested changes included removing the backdrop/tile that appeared behind clothing pieces on the outfit board, allowing clothing pieces to be resized directly on the board, clearly showing which clothing pieces had already been added to the outfit, making the category chips clearly scrollable, improving the empty outfit-board area, adding an Undo option after clearing an outfit, and updating the subtitle so users would understand that clothing pieces could either be tapped or dragged onto the board. I also asked Claude to make the resizing functionality persistent by adding a `scale` value to `outfit_items` and updating the related model and data-handling logic so the selected size of each clothing piece could be saved and restored.
- **What it gave back:** Claude modified the existing Outfit Builder and its supporting functionality to implement the requested improvements. Clothing pieces could now be resized on the outfit board, and the selected scale could be saved as part of the outfit instead of being lost when the outfit was reopened. Claude also improved the interaction of the Outfit Builder by removing the unnecessary visual backdrop behind individual clothing pieces, making it clearer when a clothing item was already being used in the current outfit, improving the category-chip area so users could recognize that more categories were available by scrolling, and improving the empty board state. The clear-outfit behavior was also updated to provide an Undo option, and the subtitle was changed to explain that clothing pieces could be tapped or dragged onto the board.
- **What I kept, what I changed, and why:** I kept the existing Outfit Builder structure, interaction pattern, and visual design because I did not want the feature redesigned from scratch. My goal was to improve the usability of the existing implementation based on problems I identified during testing. I kept the resizing functionality because it gives users more control over how clothing pieces are arranged on the outfit board, and I kept the database migration and related model/store changes because the `scale` value needs to persist when an outfit is saved and reopened. I also kept the Undo behavior because accidentally clearing an outfit should not force the user to rebuild it from the beginning. I reviewed the generated changes against the existing Love My Closet design and project structure and made sure the improvements felt like part of the existing application rather than a completely separate feature. The changes were committed together because the requested Outfit Builder improvements were implemented during the same development session and several of the changes, especially resizing, were connected across the UI, model, store, and database.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/234bd001b5073d4f6e8a1489e167ba861e82f947

## 2. Where the AI got it wrong

### Case 1 - Favorites Became a Separate Navigation Tab

- **What it gave me:** Claude added Favorites as a separate item in the bottom navigation, making it a sixth main navigation destination.
- **What was wrong with it:** Favorites was supposed to be part of the Closet feature, not a separate main section. Adding another navigation tab made the bottom navigation more crowded and changed the navigation indexes, which could cause the wrong screen to open when a navigation item was selected.
- **What I did instead:** I removed the separate Favorites tab and moved Favorites into the Closet category/filter row. Users could then access their favorite clothing items directly from the Closet without navigating to another main section. I also corrected the Closet navigation index and Home navigation mapping so the existing navigation destinations continued to open the correct screens.
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/48d372d46c324c2046713551f6e568d2db71ab7c](https://github.com/sofiademesa/love-my-closet/commit/48d372d46c324c2046713551f6e568d2db71ab7c)

### Case 2 - Outfit Diary Empty State Had Redundant Actions

- **What it gave me:** Claude generated an Outfit Diary empty state with both a plus icon and a "Log Outfit" button that performed essentially the same action.
- **What was wrong with it:** The two controls duplicated the same functionality instead of providing one clear next step. The empty state also looked too plain and did not provide enough visual context to communicate what users could do when they had not logged any outfits yet.
- **What I did instead:** I removed the redundant action and kept one clear call-to-action positioned in the lower-right area. I added an outfit illustration and a supporting empty-state message to make the screen more informative. I also adjusted the spacing and padding so the illustration, message, and remaining action would form a more balanced layout.
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/fc5c764003928af801fc5edf2e07a525eee8fc7c](https://github.com/sofiademesa/love-my-closet/commit/fc5c764003928af801fc5edf2e07a525eee8fc7c)

### Case 3 - Language Feature Did Not Work as Intended

- **What it gave me:** Claude initially implemented the Language option in the Profile page as a feature for changing the app's language. However, the translation functionality did not work properly, and the app's content could not be translated as intended.
- **What was wrong with it:** The Language feature did not meet my expectations because changing the language did not result in a reliable translation experience throughout the app. Rather than keeping a feature that was not working as intended, I decided to change the direction of the feature.
- **What I changed and why:** I replaced the Language option with an Accessibility feature and asked Claude to implement three settings: Text Size (Small, Default, and Large), Reduce Motion (On/Off), and High Contrast (On/Off). I also wanted these settings to affect the entire app instead of only the Accessibility page. During testing, I found that the initial High Contrast implementation made the existing pink color palette too bright and neon-like. I asked Claude to revise the colors using calmer, darker shades while preserving the original backgrounds and overall design. I chose Accessibility because it provided practical usability improvements that I could test and refine instead of keeping the unsuccessful translation feature.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/e163012452ff9cc644e9e2885bcd399fd853285f

### Case 4 - Background Removal Initially Used a Paid API

- **What it gave me:** When I first asked Claude to implement background removal for clothing photos, its initial approach relied on an external paid background-removal API.
- **What was wrong with it:** I wanted the feature to work with my existing project setup without depending on a paid service or requiring ongoing API credits. Introducing another external service would also add an unnecessary dependency to the photo-processing workflow.
- **What I did instead:** I rejected the paid API approach and directed Claude to use the existing local/web background-removal setup. The final implementation uses the U²-Net/ONNX-based approach with ONNX Runtime Web. Claude assisted with integrating the process into the Add Clothes photo flow, including image selection, background-removal processing, previewing the result, and allowing users to undo the operation or use the processed photo. I also reviewed the implementation during testing and addressed the model-path issue so the application could locate the model from the expected web directory.
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/7f38864e556397361a7469e8278bd3fe20af4b8b](https://github.com/sofiademesa/love-my-closet/commit/7f38864e556397361a7469e8278bd3fe20af4b8b)

## 3. Who wrote what

### Written by Me - Initial Project Setup and Configuration

- **Files:** `README.md`, `lib/main.dart`, `lib/theme.dart`, and initial project assets
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a](https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a)
- **What it does and why it is built this way:** I personally worked on the initial Flutter project setup, dependencies, web entry point, fonts, images, and project documentation. I also initially wrote parts of `main.dart` and `theme.dart` before using Claude to help refine and complete specific implementation details. These files established the foundation for the application's entry point, shared styling, and initial assets. I wanted the project structure and visual resources to be in place before developing the rest of the application.

### Written by Me - Dynamic User Name

- **Files:** `lib/features/profile/screens/profile_screen.dart` and related Profile implementation
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/21c2f46c571d64b3438f5a90d850afe6a336a9b9
- **What it does and why it is built this way:** I implemented the dynamic user-name functionality so the Profile and Home screens could display the name associated with the current user instead of showing a fixed name for everyone. This makes the application more personal and allows the displayed information to reflect the account being used. I used the user's information as the source for the displayed name so the greeting and profile details could remain consistent.

### Written by Me - Supabase Database Configuration

- **Files:** Supabase database schema, table relationships, environment configuration, client connection, and Row Level Security policies
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/591c9aafd44327452b8b65727e31326610a963a5
- **What it does and why it is built this way:** I personally handled the Supabase project setup and configuration, including the environment variables, database schema, table relationships, and Row Level Security (RLS) policies. I decided how the data should be organized so that information such as clothing items and outfits could be associated with the correct user. I also configured and checked the database settings through the Supabase dashboard and tested the database behavior. Although I used Claude to assist with parts of the integration, I worked directly with Supabase and made the backend configuration decisions myself. This is the part of the project I understand best because I learned how the database structure, relationships, and RLS policies work together to support persistent data and restrict access to user-specific records.
  
### Written by Me - Help & Support Content

- **Files:** `lib/features/help_support/` and related Help & Support screen files
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/f59f94a169bf1681e94ef3db928fcf7da6653b70](https://github.com/sofiademesa/love-my-closet/commit/f59f94a169bf1681e94ef3db928fcf7da6653b70)
- **What it does and why it is built this way:** I wrote the actual Help & Support content, including the Getting Started, Managing Closet, Planning Outfits, Having an Issue, and Need More Help sections. The content explains how users can start using the application, manage their clothing collection, plan outfits, and find assistance when they encounter a problem. I decided to keep the information within the existing screen instead of creating separate pages or unnecessary expandable components. Claude helped translate my content into the Flutter interface, but I wrote the explanations and decided which topics users needed to see.

### Written by Me - About Love My Closet Content

- **Files:** `lib/features/about/` and related About screen files
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/7aba06a18fa145c5c3b175558d57f194f0c034cc](https://github.com/sofiademesa/love-my-closet/commit/7aba06a18fa145c5c3b175558d57f194f0c034cc)
- **What it does and why it is built this way:** I wrote the About page content, including the application description, purpose, features, "Made to Be Loved Again" section, developer introduction, and contact information. I decided how to explain the purpose of Love My Closet and communicate its focus on helping users make better use of the clothes they already own. Claude helped implement my content in Flutter and make the email and LinkedIn links interactive, but the information and content decisions came from me.

### Written by Me - Bottom Navigation UI Redesign

- **Files:** `lib/widgets/bottom_nav_bar.dart` and `lib/theme.dart`
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f
- **What it does and why it is built this way:** I redesigned the visual presentation of the existing bottom navigation bar without replacing its underlying navigation functionality. I changed the primarily icon-based layout into a floating pill-style navigation bar where the active section expands to display both its icon and label, while the inactive sections remain represented by icons. For example, when the user selects Closet, its icon and "Closet" label appear together in the expanded active item. I made this change because the original icon-only design did not make the current section immediately clear. The redesign improved the visual hierarchy while preserving the existing five main destinations: Home, Closet, Style, Diary, and Profile.

### Written by Me - Hidden Gems and Bottom Navigation Refinements

- **Files:** `lib/widgets/hidden_gem_card.dart`, `lib/screens/home/hidden_gems_sheet.dart`, and `lib/widgets/bottom_nav_bar.dart`
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f](https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f)
- **What it does and why it is built this way:** I refined the Hidden Gems cards to make clothing recommendations easier to see and interact with. I increased the clothing thumbnail size from 56px to 96px and moved it above the text, giving the clothing image more visual importance. I also replaced the small inline "Wear Again" chip with a full-width, 48px-tall button containing an icon so the main action would be easier to notice and select. I expanded the Hidden Gems sheet from two items to six and increased its height from 55% to 75% to accommodate the larger cards. I also refined the bottom navigation layout so the full "Outfit Builder" label would not push the Profile icon off-screen. Instead of shortening the feature name, I retained the full label and improved the responsive layout to accommodate narrower screens and larger accessibility text. These changes improved the presentation of clothing recommendations while keeping the navigation usable across different screen sizes.

### Written by Me - Redesigned Closet Category Icons

- **Files:** `lib/data/filter_icons.dart`, `lib/widgets/filter_chips.dart`, `assets/images/icon_bottoms.png`, `assets/images/icon_dresses.png`, `assets/images/icon_outerwear.png`, `assets/images/icon_shoes.png`, `assets/images/icon_tops.png`, and related Closet screens
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/55f1eff216148104a1d1203043e4daf97eec741a](https://github.com/sofiademesa/love-my-closet/commit/55f1eff216148104a1d1203043e4daf97eec741a)
- **What it does and why it is built this way:** I redesigned the Closet category icons because the original filters did not have a consistent visual representation, and some existing icons did not clearly match their clothing categories. I created dedicated icons for Tops, Bottoms, Dresses, Outerwear, and Shoes and connected them through a shared mapping in `filter_icons.dart`. The filter chips use this mapping to display the appropriate icon for each category. Keeping the mapping in one place makes the category icons easier to maintain and helps ensure that the same clothing category is represented consistently across the Closet-related screens.

### Written by Me - Favicon and Web App Icons

- **Date:** 2026-10-07
- **Files:** `web/favicon.ico`, `web/favicon.png`, `web/icons/Icon-192.png`, `web/icons/Icon-512.png`, `web/icons/Icon-maskable-192.png`, `web/icons/Icon-maskable-512.png`, `web/icons/apple-touch-icon.png`, `web/index.html`, and `web/manifest.json`
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/04c014645650e1bdbbd74bdc7c4640bfc67689b3](https://github.com/sofiademesa/love-my-closet/commit/04c014645650e1bdbbd74bdc7c4640bfc67689b3)
- **What it does and why it is built this way:** I created the Love My Closet favicon and web app icons to replace the default Flutter branding with the application's own visual identity. I prepared the favicon, 192px and 512px icons, maskable icons, and Apple touch icon. I then connected these assets through `web/index.html` and `web/manifest.json` so the browser and installable web application could use the correct branding. I made these changes because I wanted the web version of Love My Closet to display its own identity in the browser tab and when installed, rather than use the default Flutter icons.

### Written by Me - Automated Tests

- **Files:** `test/profile_test.dart`, `test/closet_test.dart`, `test/outfit_test.dart`, `test/background_removal_test.dart`, and `test/auth_test.dart`
- **Commit:** [https://github.com/sofiademesa/love-my-closet/commit/c24cecfda0f98936991e3e4d22da2ab08b9bca17](https://github.com/sofiademesa/love-my-closet/commit/c24cecfda0f98936991e3e4d22da2ab08b9bca17)
- **What it does and why it is built this way:** I wrote automated tests to verify the application's core behavior, including valid operations, invalid input, failed saves, logged-out actions, and background-removal errors. I wanted to test the underlying logic instead of relying only on manually opening screens and clicking buttons.

  - **`test/profile_test.dart`** — Tests the display-name fallback, rejects a blank display name, and verifies that the Notifications and Hidden Gems settings are rolled back when saving fails. It also covers Text Size, Reduce Motion, and High Contrast accessibility settings.
  - **`test/closet_test.dart`** — Tests the `ClothingItem` model, including its favorite state and `copyWith` behavior, as well as the available clothing colors and categories. It also covers an empty closet and verifies that adding, deleting, or favoriting clothing items fails appropriately when the user is logged out.
  - **`test/outfit_test.dart`** — Tests the allowed scaling range for outfit pieces, including the minimum of `0.4` and maximum of `3.0`. It also covers copying an outfit piece, `SavedOutfit.copyWith`, an empty outfit store, and saving an outfit when the user is logged out.
  - **`test/background_removal_test.dart`** — Tests the Add Clothes background-removal workflow using a fake photo source and fake background remover instead of running the actual ONNX model. It covers the processing state, successful background removal, error handling, retry behavior, Undo, Use Photo, and returning to the previous screen. The fake dependencies allow the application logic to be tested without requiring the model itself to run.
  - **`test/auth_test.dart`** — Tests email validation, email-link helper functions, password visibility behavior, and the Create Account form. The form tests cover an empty submission, a password that is too short, mismatched password confirmation, and an invalid email address.

