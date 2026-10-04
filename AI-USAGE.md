### 1. How I used AI

**2026-09-20 - Setup and onboarding screens**

- **Tool:** Claude
- **What I asked for:** I set up the project foundation myself first: the theme (`theme.dart`), the fonts, the reusable widgets, and the page structure. Then I asked Claude to build the onboarding and sign-in screens on top of that setup: landing page, onboarding 1 and 2, log in, create account, and forgot password.
- **What it gave back:** The code for the onboarding and sign-in screens, connected through the onboarding flow and using my theme and widgets.
- **What I kept, what I changed, and why:** I did not accept the generated screens just because they ran. I compared them against my Figma design, and the cabinet layout did not match: the proportions and arrangement were wrong, and it ignored the design I gave it. I adjusted and revised it by hand, again and again, until it matched. For example, I resized the cabinet doors and the handles so it actually looks like a cabinet. Most of the screen code is AI-written, but I directed it, checked it against my design, and corrected the layout.
- **Commit:** [View commit](https://github.com/sofiademesa/love-my-closet/commit/185fc878db927e8f9075f74bcfe118e3bf147d4a)

**2026-09-22 - Home screen**

- **Tool:** Claude
- **What I asked for:** The Home screen from my mockup: the greeting, Hidden Gem of the Day, wardrobe stats, More Hidden Gems, and the Hidden Gems sheet, connected to Log In and Create Account.
- **What it gave back:** The Home screen, the Hidden Gems sheet, eight new reusable widgets, and navigation from the sign-in screens to Home.
- **What I kept, what I changed, and why:** I kept the screen structure and the widget split because they matched my mockup and the widgets can be reused on other screens. I checked the result in the running app, and the layout was not coherent: some boxes were about five times bigger than others and some were far too small. I adjusted the sizes and alignment myself so they matched. The names and numbers on screen are placeholder data for now.
- **Commit:** [View commit](https://github.com/sofiademesa/love-my-closet/commit/7cc1b3b69d3007c48131d0ac70fd0feca151031c)
