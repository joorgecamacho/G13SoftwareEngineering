# 🎮 Gamewise

A Flutter app to **track**, **review**, and **discover** video games, built with **Firebase** and a clean, modern UI.

# 📱 Features

- 🔐 User authentication (Email/Password and Google Sign-In)
- 🎮 Add, edit, and organize your games
- 🗂️ Create custom lists to group games
- 🔍 Search games using the RAWG.io API
- ✏️ Edit your profile (Name, Bio, Age, Location)
- ☁️ Real-time database sync with Firebase Firestore
- 🗑️ Swipe-to-delete functionality for games
- 🎨 Gradient-based, responsive design

# 📦 Tech Stack

- Flutter (Dart)
- Firebase Authentication
- Firebase Firestore
- RAWG.io API

# 🚀 Getting Started

## 📋 Prerequisites

- Flutter 3.x installed
- Firebase project created
- RAWG.io API key

## 🔧 Setup Instructions

```bash
git clone https://github.com/your-username/gamewise.git
cd gamewise

flutter pub get
```

- Configure Firebase:
  - Add `google-services.json` (Android)
  - Add `GoogleService-Info.plist` (iOS)
- Ensure you have a valid `firebase_options.dart` (use FlutterFire CLI if needed).

- Replace the RAWG API key in `search_game_page.dart`:

```dart
final url = Uri.parse(
  'https://api.rawg.io/api/games?key=YOUR_API_KEY&search=$query',
);
```

# 🖼️ App Structure

```plaintext
main.dart
 ├── login_page.dart
 ├── signup_page.dart
 ├── dashboard_page.dart
 │    ├── create_list_page.dart
 │    ├── view_list_page.dart
 │    │    ├── add_game_page.dart
 │    │    ├── edit_game_page.dart
 ├── edit_profile_page.dart
 └── search_game_page.dart
```

# 🔥 Core Screens

- LoginPage: Login with Email/Password or Google.
- SignUpPage: Register new users.
- DashboardPage: View user profile and game lists.
- CreateListPage: Create new custom lists.
- ViewListPage: View games inside a specific list.
- AddGamePage: Add a new game (manual or search).
- EditGamePage: Edit existing games.
- EditProfilePage: Edit user profile information.

# 🧠 Best Practices

- Clean separation of UI and Firebase logic.
- Real-time sync using `StreamBuilder`.
- Swipe-to-delete games with confirmation dialogs.
- Asynchronous form handling and user feedback via `SnackBar`.

# 📈 Future Improvements

- [ ] Undo delete action
- [ ] Profile pictures with Firebase Storage
- [ ] Filters for platform, genre, rating
- [ ] Pagination for large game lists
- [ ] Offline data caching

