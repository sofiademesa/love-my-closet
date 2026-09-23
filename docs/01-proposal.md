# Proposal

## The problem, in one sentence

People with around 40 clothing pieces may still rely on the same familiar items because they have difficulty keeping track of their wardrobe and often overlook clothing they rarely wear or forget they own.

## Who it is for

Love My Closet is for people who own around 40 clothing pieces but regularly rely on a smaller selection when choosing what to wear.

These users may check their physical closet, rely on memory, or browse photos on their phone when deciding what to wear. The app provides a digital way to keep track of their wardrobe and explore different outfit combinations.

## Core features

* Digital Closet: Add and manage clothing items with information such as an image, name, category, color, season, occasion, date added, last worn date, and wear count.
* Outfit Builder: Browse clothing items, select pieces, create outfit combinations, and save outfits.
* Outfit Diary: View saved outfits by date through a calendar and add optional notes.
* Hidden Gems: Identify underused clothing items using information such as their last worn date and wear count.
* User Profile: Manage basic profile information, including email, profile picture, and theme preference.

These features make up the core MVP of the application.

## Out of scope, and why

The following features are planned as stretch goals and will only be considered after the core MVP is completed:

* Smart Outfit Recommendations
* Weather-Based Outfit Suggestions
* Personalized Avatar
* Additional profile customization
* More advanced Hidden Gems recommendations
* Automatic outfit generation based on the user's wardrobe

These features require additional logic and development time, so the initial implementation focuses on completing the core features first.

## Data the app remembers, and where it is saved

The app will use Supabase as its backend for storing user data. Each user's clothing items, outfits, diary entries, and profile information will be associated with their own account.

The app stores:

* Clothing items: clothing ID, image reference, item name, category, color, season, occasion, date added, last worn date, and wear count
* Outfits: outfit ID, outfit name, clothing item IDs, assigned date, and date created
* Diary entries: diary entry ID, outfit ID, date, and notes
* User profiles: user ID, username, email, profile picture, and theme preference
* Clothing images: image files and references stored in Supabase Storage

The main database tables are `clothing_items`, `outfits`, `diary_entries`, and `profiles`.

Supabase was chosen instead of `shared_preferences` because the project aims to explore a cloud-based backend that could support the application beyond the course.

## Risks

* Hidden Gems: The feature requires rules for identifying underused clothing items without making the implementation unnecessarily complex. The initial approach is to use `lastWornDate` and `wearCount` with basic sorting and filtering.
* Supabase Integration: Supabase is a new part of the project, so connecting Flutter to the cloud database may require additional development and debugging.
* Browser Compatibility: Device-specific image selection may have limitations in the browser, so sample clothing images and data will be prepared as a fallback for demonstration.

## Changes since the last version

* Narrowed the problem to focus on clothing items that are rarely worn or easily forgotten.
* Kept Hidden Gems and User Profile in the MVP while simplifying their initial scope.
* Chose Supabase for cloud data storage and added a Supabase spike to test the integration.
* Added `image_picker` for clothing images, with sample data as a browser fallback.
* Moved advanced recommendations and automatic outfit generation to stretch goals to keep the MVP manageable.
