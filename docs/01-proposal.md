# Proposal

## The problem, in one sentence

People with around 40 clothing pieces may still rely on the same familiar items because they have difficulty keeping track of their wardrobe and often overlook clothing they rarely wear or forget they own.

## Who it is for

Love My Closet is for people who own around 40 clothing pieces but regularly rely on a smaller selection when choosing what to wear.

These users may check their physical closet, rely on memory, or browse photos on their phone when deciding what to wear. The app puts the whole closet in one place so they can see what they have, build outfits, keep track of what they wear, and bring forgotten pieces back into rotation.

## Core features

All of the core MVP features were built, tested, and deployed.

- **Digital Closet:** Add clothing items using an image selected from the gallery, along with a name, category, color, and occasion. Clothing photos can have their backgrounds removed automatically on the user's device. Items can be searched, filtered by category, occasion, color, and favorites, marked as favorites, edited, and deleted.

- **Outfit Builder:** Select clothing pieces from the Closet and place them on an outfit board. Pieces can be tapped or dragged onto the board, moved, resized, rearranged, and removed. Users can save an outfit with a name and an optional date.

- **Outfit Diary (Calendar):** View logged outfits through a monthly calendar. Users can assign outfits to dates, add an optional diary note, and tap a date to view or edit its entry.

- **Hidden Gems:** Identifies clothing pieces that have not been worn recently and surfaces them through a Wear Me suggestion and a Hidden Gems list. Users can choose a threshold of 7, 14, 30, 60, or 90 days from their Profile settings.

- **Favorites:** Users can mark clothing pieces as favorites and access them through the Favorites filter within the Closet instead of having Favorites as a separate main navigation section.

- **User Profile:** Users can edit their display name, full name, and bio, manage notifications and the Hidden Gems threshold, access Accessibility settings, view About and Help & Support information, and log out.

- **Accessibility:** Users can change Text Size, Reduce Motion, and High Contrast settings. These settings are applied across the application rather than being limited to the Accessibility screen.

- **Onboarding:** The application includes an onboarding flow with a closet-opening animation designed around the application's physical-closet metaphor.

- **Animations and interactions:** The application includes reusable animations and interaction feedback across major screens, including screen transitions, Closet and Hidden Gems animations, Outfit Builder interactions, Calendar interactions, dialogs, sheets, deletion feedback, and favorite/heart animations. The Reduce Motion setting can disable or reduce these animations.

- **Accounts:** Users can create an account with email verification, log in, use the forgot-password and set-new-password flows, and maintain a remembered session.

- **Responsive web experience:** The interface was refined to work across different screen sizes, including adjustments to the bottom navigation, clothing grids, filter controls, and accessibility font sizes.

## Out of scope, and why

The following features were planned as stretch goals and were **not built**:

- Smart Outfit Recommendations
- Weather-Based Outfit Suggestions
- Personalized Avatar
- Automatic outfit generation based on the user's wardrobe

These features were kept out of the final implementation so development could focus on completing the core wardrobe experience, account functionality, backend integration, security, accessibility, testing, and deployment.

The earlier stretch goals of additional profile customization and more advanced Hidden Gems recommendations were partly incorporated into the completed application through the Hidden Gems threshold setting and accessibility options.

## Data the app remembers, and where it is saved

The app uses **Supabase** as its backend. User data is associated with the authenticated user's account, and Row Level Security (RLS) ensures that users can only access their own data.

The main database tables are:

- **`profiles`**: display name, full name, bio, notification setting, and Hidden Gems threshold
- **`clothing_items`**: name, category, occasion, color, image path, favorite status, and created/updated timestamps
- **`outfits`**: outfit name and timestamps
- **`outfit_items`**: the clothing pieces included on an outfit board, including their position, size/scale, and stacking order
- **`calendar_entries`**: an outfit assigned to a date (`worn_on`) with an optional diary note

Clothing photos are stored as transparent PNG files in a **private Supabase Storage bucket** called `clothing-images`. Each user's files are stored in their own folder.

Email and password authentication are handled through **Supabase Auth**.

Last-worn date and times-worn are **not stored as separate fields**. Instead, these values are calculated from the user's calendar entries. This avoids storing duplicate information that could become inconsistent with the outfits the user actually logged.

Supabase was chosen instead of `shared_preferences` because the project aimed to explore a cloud-based backend and persistent user-specific data beyond a single device or session.

## Background removal

Love My Closet includes automatic background removal for clothing photos.

The feature uses an on-device/web-based **U²-Net/ONNX model with ONNX Runtime Web** rather than sending clothing photos to a paid third-party background-removal API.

The photo flow allows the user to:

1. Choose an image from the gallery.
2. Process the image and remove its background.
3. Preview the resulting transparent clothing image.
4. Undo the background removal if needed.
5. Use the processed photo for the clothing item.

The background-removal process was kept within the application so the project would not depend on a paid external API or API credits for this feature.

## Risks

The main risks identified during planning were addressed during development:

- **Hidden Gems:** Resolved. Instead of storing `lastWornDate` and `wearCount`, the application derives these values from Calendar entries and compares the number of days since an item was worn against the user's selected threshold.

- **Supabase integration:** Resolved. Authentication, database, storage, and Row Level Security were integrated into the application. RLS was also tested with separate accounts to verify that one account could not access another user's data.

- **Browser compatibility:** Resolved. Gallery image selection and the background-removal flow were adapted for the web build. The application was deployed as a web application, so the planned sample-image fallback was not required.

- **Background-removal cost:** Resolved. The initial approach considered an external background-removal API, but this was rejected because it could require paid credits. The final implementation uses the project's on-device/web ONNX-based approach instead.

- **Responsive layout:** Resolved. The application was tested and refined for different screen widths and accessibility font sizes. The bottom navigation was adjusted using flexible layouts and text handling so labels such as "Outfit Builder" could remain readable without causing overflow.

- **Email delivery:** A remaining limitation is Supabase's built-in email sender, which is rate-limited. When many users request emails within a short period, confirmation or password-reset emails may be delayed. A custom SMTP provider would address this limitation.

## Testing

Automated tests were added to verify important application behavior in addition to manually testing the application.

The tests cover:

- **Profile:** Display name fallback, blank-name validation, rollback when settings fail to save, Text Size, Reduce Motion, and High Contrast.
- **Closet:** `ClothingItem`, favorites, `copyWith`, colors, categories, empty closet behavior, and logged-out add/delete/favorite behavior.
- **Outfit:** Outfit piece scale limits, copying outfit pieces, `SavedOutfit.copyWith`, empty outfit state, and logged-out save behavior.
- **Background Removal:** Processing state, successful removal, errors, retry behavior, Undo, Use Photo, and returning from the flow.
- **Authentication:** Email validation, email-link helpers, password visibility, Create Account validation, short passwords, mismatched passwords, and invalid email addresses.

The background-removal tests use fake photo and background-removal dependencies so the application flow can be tested without requiring the actual ONNX model to run during every test.

## Security and deployment

The application uses Supabase Row Level Security to isolate user data.

The project includes RLS policies for the application's database tables and storage bucket. An RLS isolation test was also created to verify that a second account cannot access another user's data.

Clothing images are stored in a private storage bucket rather than being publicly accessible through direct links.

The web application was deployed to **GitHub Pages using GitHub Actions**.

Only the public Supabase URL and publishable key are used by the deployed application. These values are stored as repository secrets, and the git history was scanned for accidentally committed secrets.

## Changes since the last version

- Replaced the planned `lastWornDate` and `wearCount` columns with values calculated from Calendar entries.
- Removed the planned `season` field. Clothing items use category, occasion, and color instead.
- Replaced the original planned diary structure with `calendar_entries` and added `outfit_items` for individual clothing pieces placed on the Outfit Builder board.
- Added persistent outfit-piece position, scale, and stacking order.
- Changed Favorites from a separate navigation destination into a Closet filter.
- Added gallery image selection for clothing photos.
- Added automatic on-device/web background removal using the U²-Net/ONNX approach.
- Added transparent clothing previews and the ability to undo the background-removal result.
- Added resizable clothing pieces in the Outfit Builder.
- Added the Outfit Diary calendar and connected it to shared outfit data.
- Added Profile functionality with editable user information, notifications, Hidden Gems threshold, About, Help & Support, and Log Out.
- Added Accessibility settings for Text Size, Reduce Motion, and High Contrast.
- Added a floating pill-style bottom navigation while retaining the five main sections: Home, Closet, Outfit Builder, Diary, and Profile.
- Redesigned the Closet category filters with custom category icons for Tops, Bottoms, Dresses, Outerwear, and Shoes.
- Refined the Closet layout with a fixed header and independently scrolling clothing grid.
- Improved clothing cards, empty states, Hidden Gems cards, and responsive navigation behavior.
- Added a reusable app-wide animation system while keeping Reduce Motion functional.
- Added full email account flows, including verification, login, forgot password, set new password, and remembered sessions.
- Added automated tests for authentication, Profile, Closet, Outfit Builder, and background-removal behavior.
- Added Row Level Security and tested user-data isolation.
- Added a private Supabase Storage bucket for clothing images.
- Added the Love My Closet favicon and web application icons.
- Deployed the web application to GitHub Pages using GitHub Actions.
