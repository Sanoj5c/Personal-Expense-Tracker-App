# Personal Expense Tracker App

A mobile application built using Flutter that helps users track their daily expenses and manage their personal budget. The app allows users to record income and expenses, view transaction history, and monitor their spending habits.

## Features
- Add income and expenses
- View transaction history
- Categorize expenses (Food, Travel, Bills, etc.)
- Real-time data storage using Firebase
- Simple and user-friendly interface
- Edit and delete transactions
- View total balance and spending summary

## Technologies Used
- Flutter – Mobile app development framework
- Dart – Programming language
- Firebase – Backend services
  - Firebase Authentication
  - Cloud Firestore Database

## Project Structure
expense-tracker-flutter
│
├── lib
│   ├── main.dart
│   ├── models
│   ├── screens
│   ├── widgets
│   └── services
│
├── android
├── ios
├── pubspec.yaml
└── README.md

## Setup Instructions

1. Clone the repository

git clone https://github.com/yourusername/expense-tracker-flutter.git

2. Navigate to the project directory

cd expense-tracker-flutter

3. Install dependencies

flutter pub get

4. Run the application

flutter run

## Firebase Setup
1. Create a project in the Firebase Console
2. Add an Android or iOS app
3. Download the configuration file
   - google-services.json for Android
   - GoogleService-Info.plist for iOS
4. Enable Cloud Firestore
5. Enable Firebase Authentication

## Future Improvements
- Monthly expense reports
- Charts and analytics
- Budget limit alerts
- Dark mode
- Multi-device synchronization

## Author
Sanoj Dayarathna

Computer Science Undergraduate interested in Full-Stack Development, UI/UX Design, and AI/ML.
