# Volunteer Varna

**Volunteer Varna** is a mobile app (currently) built for Android which connects volunteers with campaigns and helps organizers find enthusiastic people to join their cause.

## 🚀 Key Features

### 🔐 Authentication & User Management
* **Hybrid Auth System:** Supports Email/Password registration and Google / Facebook Sign-In.
* **Profile Management:** Users can edit their profiles, upload avatars, and track their progress.

### 📢 Campaign Management
* **Create Campaigns:** A guided, multi-step form (Wizard style) for organizers to create events:
    * *Step 1:* Basic Info (Title, Description)
    * *Step 2:* Date & Time selection with validation.
    * *Step 3:* Image upload and final review.
* **Browse & Filter:** Real-time feed of active campaigns.
* **Bookmarks:** Users can save campaigns to their personal list.

### 💬 Real-Time Communication
* **Group Chats:** Every campaign has a dedicated chat room for accepted volunteers.
* **Instant Updates:** Powered by Firestore streams for real-time messaging.

### 🎮 Gamification (Leveling System) - In development
* **XP System:** Volunteers earn experience points (XP) for participating in campaigns.
* **Levels:** Dynamic user levels based on contribution history, encouraging consistent volunteering.

---

## 🔮 Future Improvements

* [ ] Dynamic homepage custom built for the user
* [ ] Push Notifications for new messages and campaign reminders
* [ ] Dark Mode and personalisation
* [ ] Gamification, experience levels, more social features

---

## 🛠️ Tech Stack

* **Frontend:** [Flutter](https://flutter.dev/) (Dart)
* **Backend / BaaS:** [Firebase](https://firebase.google.com/)
    * **Firebase Auth:** User identification.
    * **Cloud Firestore:** NoSQL database for storing users, campaigns, and chats.
    * **Firebase Storage:** Hosting campaign images and user avatars.

---

## 🏁 Getting Started

To run this project locally:

### Prerequisites
* Flutter SDK installed.
* A Firebase project set up.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ZvezdiPro/volunteer-varna.git
    cd volunteer-varna
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    * Create a project in the Firebase Console.
    * Add Android/iOS apps in the console.
    * Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS).
    * Place them in `android/app/` and `ios/Runner/` respectively.

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🏢 For NGOs & Organizations

We are constantly looking to expand our network of trusted partners! **Volunteer Varna** provides specific tools designed to help Non-Governmental Organizations (NGOs) manage their events more efficiently.

### Why join us?
* **Targeted Audience:** Reach people specifically looking to volunteer in Varna (Bulgaria - coming later!).
* **Management Tools:** Easily track participants and communicate with them via dedicated chat rooms.
* **Gamification:** Our XP system motivates volunteers to show up and perform well.

In order to join, please contact us at zvezdipenev@gmail.com and we'll create a special account as an NGO!

---
## 📫 Contact
### Developers:
* **Zvezdi** - *Lead Developer*
* **martinkab07** - Backend Dev + Tester [(github)](https://github.com/martinkab07)

Feel free to reach out if you have any questions or suggestions about the project!

* **Email:** zvezdipenev@gmail.com
* **GitHub:** [github.com/ZvezdiPro](https://github.com/ZvezdiPro)

Project Link: [https://github.com/ZvezdiPro/volunteer-varna](https://github.com/ZvezdiPro/volunteer-varna)
