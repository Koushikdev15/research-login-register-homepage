# Research CSE - Flutter Research Management Application

## 📱 Project Overview

Research CSE is a comprehensive Flutter-based research management application for educational institutions, featuring role-based access control for Admins, Faculty, and Students with Firebase backend integration.

## ✅ Completed Components

### 1. **Project Structure**
```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   └── faculty_model.dart
├── services/         # Business logic & Firebase operations
│   ├── auth_service.dart
│   ├── faculty_service.dart
│   └── storage_service.dart
├── providers/        # State management
│   ├── auth_provider.dart
│   └── faculty_provider.dart
├── screens/          # UI screens
│   ├── login_selection_screen.dart
│   └── faculty/
│       ├── faculty_login_screen.dart
│       ├── faculty_registration_screen.dart (TO BE CREATED)
│       └── faculty_dashboard.dart (TO BE CREATED)
├── widgets/          # Reusable widgets
└── utils/            # Utilities & constants
    ├── constants.dart
    └── validators.dart
```

### 2. **Data Models**
- ✅ `UserModel` - Base user with role-based authentication
- ✅ `PersonalInfo` - Faculty personal information
- ✅ `ResearchIDs` - Vidwan, Scopus, ORCID, Google Scholar IDs
- ✅ `WorkExperience` - Institution experience records
- ✅ `CITExperience` - Years at CIT
- ✅ `EducationQualification` - Academic qualifications

### 3. **Services**
- ✅ **AuthService** - Complete authentication (Email/Password, Google Sign-In, Phone)
- ✅ **FacultyService** - CRUD operations for all faculty data
- ✅ **StorageService** - Profile picture uploads, image picking

### 4. **Validators**
- ✅ Email, Password, Phone validation
- ✅ PAN, Aadhar validation (Indian format)
- ✅ ORCID ID validation
- ✅ Age, Year, Duration validation
- ✅ Date validation (DD/MM/YYYY)
- ✅ Cross-field validations (joining date vs birth date, end yearvs start year)

### 5. **State Management**
- ✅ **AuthProvider** - Authentication state, login/logout
- ✅ **FacultyProvider** - Faculty data state management

### 6. **Screens Completed**
- ✅ **LoginSelectionScreen** - Beautiful gradient UI with 3 role options
- ✅ **FacultyLoginScreen** - Email/Password + Google Sign-In, forgot password, email verification

## 🚧 Components To Be Created

### High Priority
1. **FacultyRegistrationScreen** - Multi-section registration form
2. **FacultyDashboard** - Home, Research, FDB tabs
3. **HomePage** - Profile picture, user info display, logout
4. **ResearchPage** - Research management (placeholder)
5. **FDBPage** - Faculty database page (placeholder)

### Widgets
1. **PersonalInfoForm** - Registration section 1
2. **ResearchIDsForm** - Registration section 2
3. **WorkExperienceCard** - Dynamic work experience list
4. **EducationQualificationCard** - Dynamic education list
5. **ProfilePictureWidget** - Upload/display profile picture
6. **InfoDisplayCard** - Expandable information cards

### Configuration
1. **Firebase Configuration** - `google-services.json` (Android) & `GoogleService-Info.plist` (iOS)
2. **Main.dart** - App initialization with providers
3. **Firebase Security Rules** - As provided in the specification

## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK (3.38.9 or higher)
- Firebase account
- Android Studio / VS Code
- Git

### Dependencies
```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.7
  google_sign_in: ^6.2.2
  provider: ^6.1.2
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  intl: ^0.19.0
  email_validator: ^3.0.0
  flutter_svg: ^2.0.16
  shared_preferences: ^2.3.4
  flutter_spinkit: ^5.2.1
```

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/Koushikdev15/research-login-register-homepage.git
cd research-login-register-homepage
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android/iOS apps
- Download `google-services.json` (Android) → `android/app/`
- Download `GoogleService-Info.plist` (iOS) → `ios/Runner/`
- Enable Authentication (Email/Password, Google Sign-In)
- Create Firestore Database
- Create Firebase Storage bucket

4. **Configure Firebase Authentication**
- Enable Email/Password authentication
- Enable Google Sign-In (add SHA-1 key for Android)
- Configure authorized domains

5. **Deploy Firebase Security Rules**
- Use the rules provided in the project specification
- Deploy via Firebase Console or CLI

6. **Run the app**
```bash
flutter run
```

## 📊 Database Schema

### Firestore Structure
```
users/{userId}/
├── email, phoneNumber, role, createdAt, lastLogin, profilePictureURL
├── personalInfo/{info}/
│   └── name, designation, department, age, DOB, DOJ, PAN, Aadhar, contacts, email
├── researchIDs/{ids}/
│   └── vidwanId, scopusId, orcidId, googleScholarId
├── workExperience/{experienceId}/
│   └── institutionName, yearsOfExperience, addedAt
├── citExperience/{experience}/
│   └── yearsInCIT
├── educationQualification/{qualificationId}/
│   └── institutionName, course, startYear, endYear, duration, addedAt
└── profile/{profileId}/
    └── profilePictureURL, updatedAt
```

## 🎨 UI/UX Features

- **Material Design 3** principles
- **Gradient backgrounds** for visual appeal
- **Smooth animations** and transitions
- **Form validation** with real-time feedback
- **Loading states** with spinners
- **Error handling** with user-friendly messages
- **Responsive design** for various screen sizes

## 🔐 Security Features

- Role-based access control (RBAC)
- Email verification required
- Secure password validation (8+ chars, uppercase, lowercase, number)
- Firebase Security Rules enforcement
- Owner-based document access
- Image size validation (max 5MB)

## 📝 Form Validation Rules

| Field | Rules |
|-------|-------|
| Name | Min 3 chars, letters only |
| Email | Valid email format |
| Password | 8+ chars, uppercase, lowercase, number |
| Phone | 10 digits, starts with 6-9 |
| PAN | ABCDE1234F format |
| Aadhar | 12 digits |
| Age | 22-70 years |
| ORCID | 0000-0002-1825-0097 format |
| Year | 1950 - current+5 |

## 🚀 Next Steps

1. Create Faculty Registration Screen with multi-step form
2. Implement Faculty Dashboard with navigation tabs
3. Build Home Page with profile display
4. Add profile picture upload functionality
5. Create Research Page (future feature)
6. Create FDB Page (future feature)
7. Add Student and Admin modules
8. Implement offline support
9. Add analytics and crashlytics
10. Write unit and widget tests

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ⏳ Web (future)
- ⏳ Windows/Linux/macOS (future)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is part of an educational initiative.

## 👥 Authors

- Koushik P (@Koushikdev15)

## 📞 Support

For issues or questions, please create an issue in the GitHub repository.

---

**Version:** 1.0.0  
**Last Updated:** February 5, 2026  
**Status:** In Development 🚧
