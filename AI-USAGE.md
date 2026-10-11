# AI Usage Documentation

> **Disclaimer:** This AI usage documentation was compiled and documented late in the project. The entries below are based on my actual AI-assisted work, and the corresponding commit history remains visible in the repository for verification. The commit links are provided to show the changes associated with each AI-assisted task.

## 1. How I used AI

I used AI extensively to work more efficiently, develop features, troubleshoot issues, and learn throughout the development of Love My Closet. However, I did not blindly accept its output. I reviewed, tested, and revised the generated code based on my designs, requirements, and own judgment.

### 2026-09-20 - Setup and Onboarding Screens

- **Tool:** Claude
- **What I asked for:** I set up the project foundation myself first: the theme (`theme.dart`), the fonts, the reusable widgets, and the page structure. I then asked Claude to build the onboarding and sign-in screens on top of that setup: landing page, onboarding 1 and 2, log in, create account, and forgot password.
- **What it gave back:** The code for the onboarding and sign-in screens, connected through the onboarding flow and using my theme and widgets.
- **What I kept, what I changed, and why:** I did not accept the generated screens just because they ran. I compared them against my Figma design, and the cabinet layout did not match: the proportions and arrangement were wrong, and it ignored the design I gave it. I adjusted and revised it by hand, again and again, until it matched. For example, I resized the cabinet doors and the handles so it actually looks like a cabinet. 
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a

### 2026-09-22 - Home Screen

- **Tool:** Claude
- **What I asked for:** I asked Claude to implement the Home screen based on my mockup, including the greeting, Hidden Gem of the Day, wardrobe statistics, More Hidden Gems, and the Hidden Gems sheet, connected to Log In and Create Account.
- **What it gave back:** Claude generated the Home screen, the Hidden Gems sheet, eight new reusable widgets, and navigation from the sign-in screens to Home.
- **What I kept, what I changed, and why:** I kept the screen structure and widget split because they matched my intended design and allowed the components to be reused on other screens. I checked the implementation in the running app and found that the layout was not consistent: some boxes were about five times bigger than others, while some were too small. I manually adjusted the sizes and alignment until they matched my design. The names and numbers displayed on the screen were placeholder data for this commit.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/7cc1b3b69d3007c48131d0ac70fd0feca151031c

### 2026-09-23 - Closet Feature Implementation and Clothing Card Refinement

- **Tool:** Claude
- **What I asked for:** Implement the Closet flow, including viewing clothes, adding and editing items, uploading photos, viewing item details, searching, filtering, and reusable clothing cards.
- **What it gave back:** Claude generated the main Closet screens, clothing item model, photo picker, search bar, filter chips, dropdown, empty state, and clothing card components. The same clothing card design was also used in areas such as the Home tab and Hidden Gems section.
- **What I kept, what I changed, and why:** I kept the overall Closet workflow and component structure because it covered the functionality I needed, but I identified several problems with the generated clothing card design during review. In the Closet tab, the Edit and Delete actions looked like metadata tags because they used the same rounded-pill treatment as categories. I changed these actions into a three-dot menu in the upper-right corner of each clothing card, keeping the Edit and Delete options accessible without permanently displaying them below the clothing item's name. I also found problems with the same card treatment in the Home tab's Hidden Gems section. The “Category” and “Occasion” tags took up too much visual space beside a very small clothing thumbnail, while the image had unused space underneath and the right side became heavily stacked. The “Style This” button also felt visually disconnected from the content above them. Afterwards, I revised the clothing card layout to create a clearer distinction between actions and metadata, give the clothing image and item name more visual importance, reduce unnecessary stacking, and improve the spacing and hierarchy of the card. I also adjusted the layout so text would not be awkwardly truncated and the card would remain easier to scan.
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

### 2026-09-26 - Profile Page and Edit Profile Implementation

- **Tool:** Claude
- **What I asked for:** Help implement the Profile page based on my mockup, including an Edit Profile screen where users could enter and update their display name. I also wanted the Home page greeting to use the user's entered name instead of displaying the fixed name “Sofia.”
- **What it gave back:** Claude assisted with implementing the Profile and Edit Profile screens and the shared profile-store approach for managing profile information. It also helped establish how profile data could be accessed across screens.
- **What I kept, what I changed, and why:** I kept the Profile and Edit Profile screen structure and the shared profile-store approach because they allowed profile information to be managed in one place. I reviewed the implementation against my mockup and the intended app flow. I then implemented the dynamic user-name functionality so the Profile page and Home greeting would display the current user's information instead of a hardcoded “Sofia” value.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/4f9072aaaf508028da131f196495bb537b6b895f
- **Related Commit:** https://github.com/sofiademesa/love-my-closet/commit/21c2f46c571d64b3438f5a90d850afe6a336a9b9

### 2026-09-28 - App-Wide Animation System

- **Tool:** Claude
- **What I asked for:** I asked Claude to add animations throughout Love My Closet while keeping the Reduce Motion accessibility setting functional. I wanted the animations to feel polished and responsive without introducing unnecessary delays.
- **What it gave back:** Claude created a reusable animation toolkit in `lib/animations/app_motion.dart` and applied it to screen transitions, staggered Closet/outfit/Hidden Gems/Home animations, Outfit Builder pop-ins, press feedback, crossfades, heart animations, deletion feedback, Calendar animations, dialogs, sheets, and loading indicators.
- **What I kept, what I changed, and why:** I kept the centralized animation toolkit because it made the motion behavior more consistent across the application. I specifically did not keep artificial loading animations because the app did not have network or asynchronous operations that required a loading delay. Claude could not compile and run the Flutter application in its environment because the Flutter SDK was unavailable, so I treated the generated code as something that still required local testing.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/10e79997ac9986416592746907d7254148d5a273

### 2026-09-29 - Add Clothes Photo Background Removal Flow

- **Tool:** Claude
- **What I asked for:** I asked Claude to implement only the Add Clothes photo flow in my existing Love My Closet Flutter project. I specifically asked it to inspect and reuse the existing screen, theme, widgets, navigation, and dependencies rather than redesigning the UI. The requested flow was Take Photo/Choose from Gallery → Select Image → Remove Background → Transparent Preview → Undo/Use Photo. I also required the background-removal solution to be genuinely free, preferably on-device and open-source, with no API key or paid service.
- **What it gave back:** Claude assisted with implementing the photo-selection flow, background-removal processing, loading and error states, transparent preview, checkerboard transparency preview, background-color preview options, Undo, and Use Photo behavior. After the initial approach, the implementation was adapted to use a local ONNX model with ONNX Runtime Web. However, the September 29 implementation only connected the Choose from Gallery option to the screen. Although the photo service already contained camera-related code, the screen did not call it and did not have a Take Photo button.
- **What I kept, what I changed, and why:** I kept the photo-flow structure and the parts that integrated well with the existing Love My Closet UI. I chose the ONNX-based approach to avoid relying on a paid external service. I also kept the checkerboard preview and Undo/Use Photo actions because they made it easier to review the processed image before using it. Due to time constraints, I prioritized getting the gallery and background-removal flow working first. When the deadline was extended, I returned to the photo screen on October 10 to add the missing Take Photo functionality. The newly added camera feature initially failed during testing, so I worked on troubleshooting and revising it in a separate session (see Case 5, an entry for October 10).
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
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/48d372d46c324c2046713551f6e568d2db71ab7c

### Case 2 - Outfit Calendar Empty State Had Redundant Actions

- **What it gave me:** Claude generated an Outfit Calendar empty state with both a plus icon and a "Log Outfit" button that performed essentially the same action.
- **What was wrong with it:** The two controls duplicated the same functionality instead of providing one clear next step. The empty state also looked too plain and did not provide enough visual context to communicate what users could do when they had not logged any outfits yet.
- **What I did instead:** I removed the redundant action and kept one clear call-to-action positioned in the lower-right area. I added an outfit illustration and a supporting empty-state message to make the screen more informative. I also adjusted the spacing and padding so the illustration, message, and remaining action would form a more balanced layout.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/fc5c764003928af801fc5edf2e07a525eee8fc7c

### Case 3 - Language Feature Did Not Work as Intended

- **What it gave me:** Claude initially implemented the Language option in the Profile page as a feature for changing the app's language. However, the translation functionality did not work properly, and the app's content could not be translated as intended.
- **What was wrong with it:** The Language feature did not meet my expectations because changing the language did not result in a reliable translation experience throughout the app. Rather than keeping a feature that was not working as intended, I decided to change the direction of the feature.
- **What I changed and why:** I replaced the Language option with an Accessibility feature and asked Claude to implement three settings: Text Size (Small, Default, and Large), Reduce Motion (On/Off), and High Contrast (On/Off). I also wanted these settings to affect the entire app instead of only the Accessibility page. During testing, I found that the initial High Contrast implementation made the existing pink color palette too bright and neon-like. I asked Claude to revise the colors using calmer, darker shades while preserving the original backgrounds and overall design. I chose Accessibility because it provided practical usability improvements that I could test and refine instead of keeping the unsuccessful translation feature.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/e163012452ff9cc644e9e2885bcd399fd853285f

### Case 4 - Background Removal Initially Used a Paid API

- **What it gave me:** When I first asked Claude to implement background removal for clothing photos, its initial approach relied on an external paid background-removal API.
- **What was wrong with it:** I specifically required a genuinely free solution that would not depend on paid services or require ongoing API credits. The proposed approach did not meet this requirement.
- **What I did instead:** I rejected the paid API approach and directed Claude to use a free, on-device solution instead. The implementation was adapted to use the U²-Net/ONNX-based approach with ONNX Runtime Web, allowing background removal to run within the existing project without relying on a paid external API.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/7f38864e556397361a7469e8278bd3fe20af4b8b

### Case 5 - Camera Implementation Failed and Did Not Match the App Design

- **What it gave me:** On October 10, I returned to the Add Clothes photo flow because the September 29 implementation only supported choosing photos from the gallery. I asked Claude to add the Take Photo option, but the newly added camera functionality failed on my computer and displayed a "camera is being used by another app" error. The initial screen also used a black background and vertically stacked buttons, which did not match the existing app design.
- **What was wrong with it:** The newly added camera functionality did not work during testing, making the feature unusable as intended. The error message also did not clearly identify the underlying cause. Visually, the black background and stacked buttons were inconsistent with Love My Closet's light cream background, pink accents, and side-by-side button layouts.
- **What I did instead:** I investigated the camera error and worked through the possible causes instead of simply accepting the error message. I directed the troubleshooting toward an alternative browser-based camera implementation using `web/camera/camera.js` and the supporting Dart bridge files. I then tested the revised implementation on my computer to verify that the camera worked. I also redesigned the Add Clothes photo screen by replacing the black background with the app's light cream background, adding a white rounded photo box and pink camera icon, styling the "Take Photo" and "Choose from Gallery" options as a pink toggle, and placing the "Undo" and "Use Photo" buttons side by side. I retained the shared background-removal flow so photos from either source could be processed consistently.
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/876a55cb9d4e650ab461de501eeaf93dcd2bd144

## 3. Who wrote what

### Written by Me - Initial Project Setup and Configuration

- **Files:** `README.md`, `lib/main.dart`, `lib/theme.dart`, and initial project assets
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a
- **What it does and why it is built this way:** I personally worked on the initial Flutter project setup, dependencies, web entry point, fonts, images, and project documentation. I also initially wrote parts of `main.dart` and `theme.dart` before using Claude to help refine and complete specific implementation details. These files established the foundation for the application's entry point, shared styling, and initial assets. I wanted the project structure and visual resources to be in place before developing the rest of the application.

### Written by Me - Dynamic User Name

- **Files:** `lib/features/profile/screens/profile_screen.dart` and related Profile implementation
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/21c2f46c571d64b3438f5a90d850afe6a336a9b9
- **What it does and why it is built this way:** I implemented the dynamic user-name functionality so the Profile and Home screens could display the name associated with the current user instead of showing a fixed name for everyone. This makes the application more personal and allows the displayed information to reflect the account being used. I used the user's profile information as the source for the displayed name so the greeting and profile details could remain consistent.
  
### Written by Me - Supabase Database Configuration

- **Files:** Supabase database schema, table relationships, environment configuration, client connection, and Row Level Security policies
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/591c9aafd44327452b8b65727e31326610a963a5
- **What it does and why it is built this way:** I personally handled the Supabase project setup and configuration, including the environment variables, database schema, table relationships, and Row Level Security (RLS) policies. I decided how the data should be organized so that information such as clothing items and outfits could be associated with the correct user. I also configured and checked the database settings through the Supabase dashboard and tested the database behavior. Although I used Claude to assist with parts of the integration, I worked directly with Supabase and made the backend configuration decisions myself. This is the part of the project I understand best because I learned how the database structure, relationships, and RLS policies work together to support persistent data and restrict access to user-specific records.
  
### Written by Me - Help & Support Content

- **Files:** `lib/features/help_support/` and related Help & Support screen files
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/f59f94a169bf1681e94ef3db928fcf7da6653b70
- **What it does and why it is built this way:** I wrote the actual Help & Support content, including the Getting Started, Managing Closet, Planning Outfits, Having an Issue, and Need More Help sections. The content explains how users can start using the application, manage their clothing collection, plan outfits, and find assistance when they encounter a problem. I decided to keep the information within the existing screen instead of creating separate pages or unnecessary expandable components. Claude helped translate my content into the Flutter interface, but I wrote the explanations and decided which topics users needed to see.

### Written by Me - About Love My Closet Content

- **Files:** `lib/features/about/` and related About screen files
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/7aba06a18fa145c5c3b175558d57f194f0c034cc
- **What it does and why it is built this way:** I wrote the About page content, including the application description, purpose, features, "Made to Be Loved Again" section, developer introduction, and contact information. I decided how to explain the purpose of Love My Closet and communicate its focus on helping users make better use of the clothes they already own. Claude helped implement my content in Flutter and make the email and LinkedIn links interactive, but the information and content decisions came from me.

### Written by Me - Bottom Navigation UI Redesign

- **Files:** `lib/widgets/bottom_nav_bar.dart` and `lib/theme.dart`
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/18bf985996b0d90363b654ee0931d30fa7bed37f
- **What it does and why it is built this way:** I redesigned the visual presentation of the existing bottom navigation bar without replacing its underlying navigation functionality. I changed the primarily icon-based layout into a floating pill-style navigation bar where the active section expands to display both its icon and label, while the inactive sections remain represented by icons. For example, when the user selects Closet, its icon and "Closet" label appear together in the expanded active item. I made this change because the original icon-only design did not make the current section immediately clear. The redesign improved the visual hierarchy while preserving the existing five main destinations: Home, Closet, Outfit Builder, Calendar, and Profile.

### Written by Me - Redesigned Closet Category Icons

- **Files:** `lib/data/filter_icons.dart`, `lib/widgets/filter_chips.dart`, `assets/images/icon_bottoms.png`, `assets/images/icon_dresses.png`, `assets/images/icon_outerwear.png`, `assets/images/icon_shoes.png`, `assets/images/icon_tops.png`, and related Closet screens
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/55f1eff216148104a1d1203043e4daf97eec741a
- **What it does and why it is built this way:** I redesigned the Closet category icons because the original filters did not have a consistent visual representation, and some existing icons did not clearly match their clothing categories. I created dedicated icons for Tops, Bottoms, Dresses, Outerwear, and Shoes and connected them through a shared mapping in `filter_icons.dart`. The filter chips use this mapping to display the appropriate icon for each category. Keeping the mapping in one place makes the category icons easier to maintain and helps ensure that the same clothing category is represented consistently across the Closet-related screens.

### Written by Me - Favicon and Web App Icons

- **Date:** 2026-10-07
- **Files:** `web/favicon.ico`, `web/favicon.png`, `web/icons/Icon-192.png`, `web/icons/Icon-512.png`, `web/icons/Icon-maskable-192.png`, `web/icons/Icon-maskable-512.png`, `web/icons/apple-touch-icon.png`, `web/index.html`, and `web/manifest.json`
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/04c014645650e1bdbbd74bdc7c4640bfc67689b3
- **What it does and why it is built this way:** I created the Love My Closet favicon and web app icons to replace the default Flutter branding with the application's own visual identity. I prepared the favicon, 192px and 512px icons, maskable icons, and Apple touch icon. I then connected these assets through `web/index.html` and `web/manifest.json` so the browser and installable web application could use the correct branding. I made these changes because I wanted the web version of Love My Closet to display its own identity in the browser tab and when installed, rather than use the default Flutter icons.

### Written by Me - Automated Tests

- **Files:** `test/profile_test.dart`, `test/closet_test.dart`, `test/outfit_test.dart`, `test/background_removal_test.dart`, and `test/auth_test.dart`
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/c24cecfda0f98936991e3e4d22da2ab08b9bca17
- **What it does and why it is built this way:** I wrote automated tests to verify the application's core behavior, including valid operations, invalid input, failed saves, logged-out actions, and background-removal errors. I wanted to test the underlying logic instead of relying only on manually opening screens and clicking buttons.

  - **`test/profile_test.dart`** — Tests the display-name fallback, rejects a blank display name, and verifies that the Notifications and Hidden Gems settings are rolled back when saving fails. It also covers Text Size, Reduce Motion, and High Contrast accessibility settings.
  - **`test/closet_test.dart`** — Tests the `ClothingItem` model, including its favorite state and `copyWith` behavior, as well as the available clothing colors and categories. It also covers an empty closet and verifies that adding, deleting, or favoriting clothing items fails appropriately when the user is logged out.
  - **`test/outfit_test.dart`** — Tests the allowed scaling range for outfit pieces, including the minimum of `0.4` and maximum of `3.0`. It also covers copying an outfit piece, `SavedOutfit.copyWith`, an empty outfit store, and saving an outfit when the user is logged out.
  - **`test/background_removal_test.dart`** — Tests the Add Clothes background-removal workflow using a fake photo source and fake background remover instead of running the actual ONNX model. It covers the processing state, successful background removal, error handling, retry behavior, Undo, Use Photo, and returning to the previous screen. The fake dependencies allow the application logic to be tested without requiring the model itself to run.
  - **`test/auth_test.dart`** — Tests email validation, email-link helper functions, password visibility behavior, and the Create Account form. The form tests cover an empty submission, a password that is too short, mismatched password confirmation, and an invalid email address.

### Written by Me - Add Clothes Photo Revision

- **Files:** `lib/screens/closet/adding_item_photo_screen.dart`
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/876a55c
- **What it does and why it is built this way:** I revised the Add Clothes photo screen to make its appearance consistent with Love My Closet's existing design. I replaced the black background with the app's light cream background, added a white rounded photo box with a pink camera icon, and changed the "Take Photo" and "Choose from Gallery" options into a pink pill-shaped toggle. I also placed the "Undo" and "Use Photo" buttons side by side and retained the supporting photo instructions. These changes focused on the screen's visual layout and usability, while Case 5 documents the camera implementation problems and troubleshooting.

### Written by Me - Calendar Add Outfit Bar and Date Handling Improvements

- **Files:** `lib/screens/calendar/calendar_screen.dart`, `lib/screens/calendar/log_outfit_screen.dart`, and `lib/screens/outfit_builder/outfit_builder_screen.dart`
- **Commit:** https://github.com/sofiademesa/love-my-closet/commit/c02356cab71da11a2a3793d33d0ea7a1cf421fbf
- **What it does and why it is built this way:** I revised the Calendar screen by replacing the floating “+” button with an “Add outfit for [selected date]” bar below the outfit card. I made the bar update according to the selected date and remain visible even when an outfit was already logged, allowing users to record multiple outfits on the same day. I also connected the bar to the Log Outfit screen so the selected date would be filled in automatically. When creating a new look through the Outfit Builder, the selected date carries over when saving, and returning from the Builder takes the user back to the Calendar. Finally, I removed the dotted line below “My Calendar” to keep the screen visually consistent with the other pages. I made these changes to provide a more straightforward outfit-logging flow and ensure that outfits are recorded under the intended date.
