# Love My Closet

> Love My Closet is a digital wardrobe app that helps college students and young professionals organize their clothes, plan outfits, and rediscover pieces they rarely wear.

**Live demo:** https://sofiademesa.github.io/love-my-closet/
**Demo video:** [docs/demo.mp4](docs/demo.mp4)
**Course:** Applications Development and Emerging Technologies (6ADET), Holy Angel University
**Author:** Sofia Ryza D. De Mesa

This repository contains the final project developed for 6ADET. The repository is public for academic evaluation and portfolio purposes.

---

## Screenshots

To be updated once I finished all my screens.

| Home                                 | Detail                                   | Add                                |
| ------------------------------------ | ---------------------------------------- | ---------------------------------- |
| ![Home](docs/assets/screen-home.png) | ![Detail](docs/assets/screen-detail.png) | ![Add](docs/assets/screen-add.png) |

## What it does

Love My Closet helps users organize and make better use of the clothes they already own.

- Organize clothing items in a digital closet.
- Add, edit, and delete clothing items with details such as category, color, season, and occasion.
- Search and filter clothing items by category and other details.
- Create and save outfits using items from the closet.
- Schedule outfits and view them through an outfit diary.
- Rediscover rarely worn clothing through the Hidden Gem feature.

## Built with

|                  |                                        |
| ---------------- | -------------------------------------- |
| Framework        | Flutter                                |
| Language         | Dart                                   |
| State Management | `setState`                             |
| Storage          | Supabase                               |
| Design           | Figma                                  |
| Typography       | Young Serif (headings), DM Sans (body) |
| Version Control  | Git and GitHub                         |

## Running it yourself

Make sure Flutter is installed and configured on your computer.

Check your Flutter installation with `flutter --version`.

Clone the repository:

`git clone https://github.com/sofiademesa/love-my-closet.git`

Move into the project directory:

`cd love-my-closet`

Install the dependencies:

`flutter pub get`

Run the application:

`flutter run`

To run the web version:

`flutter run -d chrome`

### Environment variables

This project reads its configuration from a `.env` file that is **not** in the
repository. Copy `.env.example`, fill in your own values, and never commit the
result.

| Variable            | What it is                         | Where to get one                            |
| ------------------- | ---------------------------------- | ------------------------------------------- |
| `SUPABASE_URL`      | The URL of your Supabase project   | Supabase dashboard → Project Settings → API |
| `SUPABASE_ANON_KEY` | Public (anon) key for your project | Supabase dashboard → Project Settings → API |

## Privacy and secrets

Love My Closet is designed to avoid collecting unnecessary personal information. Any user data stored by the application is limited to information required for the application's features.

No API keys, passwords, or other private credentials are included in the public repository.

Sample data, screenshots, and demonstration materials should not contain real passwords, API keys, or other sensitive personal information.

## Project documentation

| Document                                                |                                         |
| ------------------------------------------------------- | --------------------------------------- |
| [Proposal](docs/01-proposal.md)                         | the problem, the users, the scope       |
| [Mockup and wireframes](docs/02-mockup.md)              | what it looks like, and the screen flow |
| [Design system](docs/03-design-system.md)               | colors, type, spacing, components       |
| [Weekly reports](docs/04-weekly-reports.md)             | what happened each week                 |
| [Demo video](docs/05-demo-video.md)                     | the recording and what it shows         |
| [Security and privacy](docs/06-security-and-privacy.md) | the checklist, filled in                |

## Project status and what is next

Love My Closet is currently under development as the final project for Applications Development and Emerging Technologies.

### Current focus

- Implementing the main Flutter application structure
- Building the Home page
- Building the digital Closet
- Implementing clothing item management
- Developing the Outfit Builder
- Developing the Outfit Diary
- Implementing the Hidden Gem feature
- Connecting the completed screens through navigation
- Testing the application before final submission

### Future improvements

Possible improvements beyond the MVP include:

- Customizable user avatars
- Smart outfit recommendations
- Weather-based outfit suggestions
- Additional wardrobe statistics
- More customization options for clothing and outfits

## Credits

- Framework: Flutter
- Language: Dart
- UI/UX design: Sofia Ryza D. De Mesa
- Design and prototyping: Figma
- Version control: Git and GitHub
- Packages and dependencies: See `pubspec.yaml`
- External assets: Credited according to their respective sources and licenses

## AI use

AI tools were used during the development of Love My Closet as learning and development aids. Claude was primarily used to guide the implementation of Flutter and Dart code, while ChatGPT and Gemini were used for troubleshooting, explaining technical concepts, and assisting with project documentation and write-ups.

The final code, design decisions, features, and project documentation were reviewed, adapted, and finalized by the author.

## Licence

MIT, see [LICENSE](LICENSE).
