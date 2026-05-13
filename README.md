# Mobile-Based Learning Management System (LMS) for Korean classes

## 📌 Project Overview
This project is a **mobile-based Learning Management System (LMS)** designed for a **Korean language class**. The system streamlines student management, payment verification, and secure access to learning materials.

## 🔥 Key Features
- **QR Code-Based Payment Verification**: Students must scan a QR code to verify payment before entering physical classes.
- **Secure Recording Management**: Only authorized students can access class recordings with encryption and device binding.
- **Automated Student & Payment Management**: Register students, track payments, and send automated reminders.
- **Mock Exam & Performance Tracking**: Online exams with automated scoring and feedback.
- **Role-Based Access Control**: Separate permissions for Admins, Teachers, Students, and Fees Checkers.
- **Push Notifications**: Alerts for payments, class schedules, and exam reminders.
- **Cross-Platform Compatibility**: Built with **Flutter** and **Firebase**, ensuring smooth performance on **Android and iOS**.

## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore, Firebase Authentication, node.js
- **Security**: Firebase Security Rules, Role-Based Access Control (RBAC), Encrypted Data Storage
- **APIs**: Google ML Kit (QR Code Scanning), PayHere (Payment Integration)
- **Notifications**: Firebase Cloud Messaging (FCM)

## 🚀 Installation & Setup
### Prerequisites
- Install **Flutter** and **Dart**
- Set up **Firebase** for authentication, Firestore, and cloud storage
- Clone the repository:
  
  ```bash
  git clone https://github.com/Ashan2K/mobile-lms.git
  cd LMS-Korean-Class
  ```
- Install dependencies:
  
  ```bash
  flutter pub get
  ```
- Configure Firebase:
   - Add google-services.json (Android) & GoogleService-Info.plist (iOS)
- Run the app:
  
  ```bash
  flutter run
  ```
  
