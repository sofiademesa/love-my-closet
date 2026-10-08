## Mockup

### Onboarding

| Onboarding 1 | Onboarding 2 | Landing | Create Account |
|:---:|:---:|:---:|:---:|
| <img src="assets/mockup-onboarding-1.png" width="150"> | <img src="assets/mockup-onboarding-2.png" width="150"> | <img src="assets/mockup-landing.png" width="150"> | <img src="assets/mockup-create-account.png" width="150"> |

| Log In | Forgot Password |
|:---:|:---:|
| <img src="assets/mockup-login.png" width="150"> | <img src="assets/mockup-forgot-password.png" width="150"> |

### Home

| Home | Hidden Gems |
|:---:|:---:|
| <img src="assets/mockup-home.png" width="150"> | <img src="assets/mockup-home-hidden-gems.png" width="150"> |

### Closet

| Closet | Item Detail | Edit Item | Add Clothes |
|:---:|:---:|:---:|:---:|
| <img src="assets/mockup-closet.png" width="150"> | <img src="assets/mockup-item-detail.png" width="150"> | <img src="assets/mockup-edit-item.png" width="150"> | <img src="assets/mockup-add-clothes.png" width="150"> |

| Background Removal | No Items Found |
|:---:|:---:|
| <img src="assets/mockup-add-clothes-bg-removal.png" width="150"> | <img src="assets/mockup-closet-empty.png" width="150"> |

### Outfit Builder

| Builder | Outfit on Board | Save Look | Saved Outfits |
|:---:|:---:|:---:|:---:|
| <img src="assets/mockup-outfit-builder.png" width="150"> | <img src="assets/mockup-outfit-builder-board.png" width="150"> | <img src="assets/mockup-outfit-builder-save.png" width="150"> | <img src="assets/mockup-outfit-builder-saved.png" width="150"> |

### Calendar

| Calendar | Log Outfit |
|:---:|:---:|
| <img src="assets/mockup-calendar.png" width="150"> | <img src="assets/mockup-calendar-log-outfit.png" width="150"> |

### Profile

| Profile | Edit Profile |
|:---:|:---:|
| <img src="assets/mockup-profile.png" width="150"> | <img src="assets/mockup-edit-profile.png" width="150"> |

## Wireframes

### Screen flow

<img src="assets/flow-diagram.png" width="420">

### Landing page group

| Landing | Log In | Sign Up | Forgot Password | Verify Account |
|:---:|:---:|:---:|:---:|:---:|
| <img src="assets/wf-landing.png" width="120"> | <img src="assets/wf-login.png" width="120"> | <img src="assets/wf-signup.png" width="120"> | <img src="assets/wf-forgot-password.png" width="120"> | <img src="assets/wf-verify-account.png" width="120"> |

### Main screens

| Home | Closet | Add/Edit Item | Outfit Builder |
|:---:|:---:|:---:|:---:|
| <img src="assets/wf-home.png" width="150"> | <img src="assets/wf-closet.png" width="150"> | <img src="assets/wf-closet-add-edit.png" width="150"> | <img src="assets/wf-outfit-builder.png" width="150"> |

| Calendar (Month) | Calendar (Day) | Profile |
|:---:|:---:|:---:|
| <img src="assets/wf-calendar-month.png" width="150"> | <img src="assets/wf-calendar-day.png" width="150"> | <img src="assets/wf-profile.png" width="150"> |


## Screens

### Onboarding 1
**On screen:** closed wardrobe illustration, the line "When 'nothing to wear' is your daily problem…", and a Next button.
**User does:** taps Next.
**Goes to:** Onboarding 2.

### Onboarding 2
**On screen:** open wardrobe illustration, the line "Maybe it's time to love your closet", Skip, and Next.
**User does:** taps Next or Skip.
**Goes to:** Landing (both buttons).

### Landing
**On screen:** Love My Closet logo and tagline, Sign Up button, Log In button.
**User does:** chooses to create an account or log in.
**Goes to:** Sign Up goes to Create Account. Log In goes to Log In.

### Create Account
**On screen:** Full Name, Email, Password, and Confirm Password fields, a Sign Up button, and an "Already have an account? Log In" link.
**User does:** fills in the form and taps Sign Up.
**Goes to:** Home after success. The Log In link goes to Log In.

### Log In
**On screen:** "Welcome Back", Email and Password fields, Remember Me, Forgot Password?, Log In button, and a "Don't have an account? Sign up" link.
**User does:** enters credentials and taps Log In.
**Goes to:** Home after success. Forgot Password? goes to Forgot Password. The Sign up link goes to Create Account.

### Forgot Password
**On screen:** email field, Send Reset Link button, and a Back to Log In link.
**User does:** enters email and taps Send Reset Link.
**Goes to:** a reset link is sent to their email. Back to Log In goes to Log In.

### Home
**On screen:** welcome greeting with avatar, Hidden Gem of the Day card (Style This / Skip), Wardrobe Stats, a row of more Hidden Gems with See More, a floating + button, and the bottom navigation.
**User does:** gets an outfit nudge, checks stats, browses unworn items.
**Goes to:** Style This goes to Outfit Builder. See More opens the Hidden Gems sheet. + goes to Add Clothes. The avatar goes to Profile. Bottom nav goes to Closet, Outfit, Calendar, or Profile.

### Home: Hidden Gems
**On screen:** a bottom sheet listing items not worn in a while, each with how many days and a Wear Again button.
**User does:** picks an item to wear again.
**Goes to:** Wear Again goes to Outfit Builder with that item. Swiping down closes the sheet back to Home.

### Closet
**On screen:** search bar, filter chips, grid of clothing cards, floating + button, and the bottom navigation.
**User does:** searches, filters, and browses items.
**Goes to:** tapping an item goes to Item Detail. + goes to Add Clothes. If nothing matches, an empty state shows with an Add Item button that also goes to Add Clothes.

### Item Detail
**On screen:** item photo, name, details (category, color, season, etc.), Add to Outfit, Edit Item, and a back arrow.
**User does:** views the item and decides what to do with it.
**Goes to:** Add to Outfit goes to Outfit Builder. Edit Item goes to Edit Item. Back returns to Closet.

### Edit Item
**On screen:** photo with a change option, editable fields, Save Changes, and Cancel.
**User does:** updates the item's details.
**Goes to:** Save Changes and Cancel both return to Item Detail.

### Add Clothes
**On screen:** photo upload area, an option to remove the background, fields for item details, Save to Closet, and Cancel.
**User does:** uploads a photo, optionally removes the background, fills in details, and saves.
**Goes to:** Save to Closet adds the item and goes to Closet. Cancel returns to the previous screen.

### Outfit Builder
**On screen:** Builder and Saved Outfits tabs, category filters, a strip of closet items, the board, and Clear and Save Outfit buttons.
**User does:** drags items onto the board to make an outfit.
**Goes to:** Save Outfit opens the Save this look sheet (outfit name, date, Cancel, Save Outfit). Saving puts the look under the Saved Outfits tab.

### Calendar
**On screen:** month calendar, the selected day's outfit summary with item thumbnails, and the bottom navigation.
**User does:** browses past outfits by date.
**Goes to:** tapping a date opens Log Outfit (outfit name, notes, Save Entry). Saving returns to the calendar with the day marked.

### Profile
**On screen:** avatar, display name, short bio, and settings (Edit Profile, Language, Notifications toggle, and more).
**User does:** manages account and app settings.
**Goes to:** Edit Profile goes to Edit Profile.

### Edit Profile
**On screen:** avatar, Display Name, Email Address, Bio, and a Save button.
**User does:** updates profile info.
**Goes to:** Save returns to Profile.
