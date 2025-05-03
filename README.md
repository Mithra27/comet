Comet

Comet is a Flutter-based mobile app that empowers people in gated communities or apartments to build stronger connections by borrowing and lending items with their neighbors. Whether it's a drill, a ladder, or a book — Comet helps you share the things you don’t use every day, creating trust and reducing waste.

Flutter Version: >= 3.29.2
Contact for contributions: mithra2718@gmail.com
GitHub: https://github.com/Mithra27

Description

Comet brings community sharing to your fingertips. It's designed to let users securely join their neighborhood community, request items they need, lend what they have, and interact directly with each other using real-time chat — all while keeping data secure through Firebase services and Two-Factor Authentication.

Key Features

User Authentication

Email & password registration and login

Secure Two-Factor Authentication (2FA)

Password reset flow

Community Management

Browse available communities and join

View community info (description, address, members)

Leave a community

(Optional) Community creation support

Item Sharing

Post item requests (title, category, image, duration)

View a real-time feed of active requests

Offer to lend items in response to requests

Accept or decline lending offers

Mark items as completed or cancelled

View your own borrowed/lent items

User Profiles

Edit your profile

View other members’ basic info

Real-time Chat

In-app messaging for requests and offers

Chats linked to specific item transactions

Notifications

Push notifications for new offers, accepted requests, new community members (admin only)

Technology Stack

Language: Dart
Framework: Flutter (3.29.2)
Backend & Services: Firebase

Authentication (with custom 2FA logic)

Cloud Firestore (for app data)

Cloud Storage (for images)

Cloud Messaging (for push notifications)

State Management: Provider
Dependency Injection: GetIt
Secure Storage: flutter_secure_storage
Navigation: Flutter Navigator or GetMaterialApp
Logging: logger package

Prerequisites

Flutter SDK: Version >= 3.29.2

Dart SDK: Included with Flutter

An IDE like VS Code or Android Studio

A physical or virtual device/emulator

Firebase Project: You'll need to configure your own Firebase project

Installation & Setup

Clone the repo:
git clone https://github.com/Mithra27/comet.git
cd comet

Set up Firebase:

Create a Firebase project

Enable Authentication, Firestore, Cloud Storage, and Messaging

Download config files (google-services.json, GoogleService-Info.plist)

Run: flutterfire configure

Follow setup guide: https://firebase.flutter.dev/docs/overview

Install dependencies:
flutter pub get

Running the App

Make sure a device is connected

Run the app using:
flutter run
For release mode:
flutter run --release

Project Structure

comet/
├── lib/
│ ├── main.dart
│ ├── config/ (Firebase & theme configs)
│ ├── core/ (Utilities, services, constants)
│ ├── features/ (Auth, Community, Items, Chat, Profile)
│ └── shared/ (Reusable widgets/layouts)
├── android/
├── ios/
├── test/
└── pubspec.yaml

Contributing

Feel like contributing? Love that.
Shoot me an email at mithra2718@gmail.com with what you're planning or submit a pull request directly via GitHub: https://github.com/Mithra27/comet
