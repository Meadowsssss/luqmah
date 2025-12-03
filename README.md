# Luqmah – Food Ordering App for HU Students

Luqmah is a Flutter-based food ordering app designed to simplify how Hashemite University students browse restaurants, view menus, and place orders.  
The backend uses **Firebase Firestore** to store restaurants, menus, and customer information.

---

## 🚀 Tech Stack

- **Flutter** (UI)
- **Dart**
- **Firebase Firestore**
- **Firebase Core**
- Works on:
  - Android
  - iOS (if configured)
  - Web
  - Windows Desktop

---

## 📚 Official Documentation (What you will be following)

### 🔗 Flutter Install  
https://docs.flutter.dev/install/manual

### 🔗 Firebase + Flutter Setup  
https://firebase.google.com/docs/flutter/setup?platform=web

---

## ✅ Prerequisites

1. **Flutter SDK**  
   Install using the official docs above.
   ```bash
   flutter doctor
   ```

2. **Git**

3. **Code editor** (VS Code recommended)

4. **Firebase CLI (optional, only for project owner)**  
   ```bash
   npm install -g firebase-tools
   ```

---

## 📥 Getting Started (For Collaborators / Friends)

### 1. Clone the repository
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Install dependencies
```bash
flutter pub get
```

---

## 🔗 Firebase Setup

### ✔ Files included in repo
- `lib/firebase_options.dart`

### ✔ Files you may need to add manually

#### Android  
```
android/app/google-services.json
```

#### iOS  
```
ios/Runner/GoogleService-Info.plist
```

#### macOS  
```
macos/Runner/GoogleService-Info.plist
```

Download from Firebase Console → Project Settings → Your Apps.

**Collaborators DO NOT run `flutterfire configure`.**

---

## ▶️ Running the App

### Windows Desktop
```bash
flutter run -d windows
```

### Android
```bash
flutter run -d android
```

### Web (Chrome)
```bash
flutter run -d chrome
```

---

## 🗂 Project Structure
```text
lib/
  main.dart
  pages/
  widgets/
  services/
  models/
  firebase_options.dart
  main.dart
```

---

## 🧪 Example: Simple Firestore Read
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> printCustomers() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('customers')
      .get();

  for (var doc in snapshot.docs) {
    print("Customer ID: ${doc.id}");
    print("Email: ${doc['email']}");
    print("First Name: ${doc['firstName']}");
    print("Last Name: ${doc['lastName']}");
    print("Password Hash: ${doc['passwordHash']}");
    print("---------------------------");
  }
}
```

---

## 🛠 Common Issues

### Version solving failed  
Make sure all collaborators use the SAME `pubspec.yaml`.

### LNK1168 (Windows build error)  
Close/kil app exe → run again.

### Firebase not initialized  
Ensure:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 👥 Collaboration Rules

- Do NOT run `flutterfire configure` unless you are changing Firebase for the entire project.
- Do NOT change package versions without committing the updated `pubspec.yaml`.
- Always run:
  ```bash
  flutter pub get
  ```

---

## 📄 License  
(Add a license if needed)
