# 🥾 TrailBuddy – Smart Hiking Companion App

TrailBuddy is a **cross-platform Flutter app** designed to make hiking safer, smarter, and more interactive.  
It enables users to **navigate offline**, **track their live location**, **report trail conditions**, and **send emergency alerts** — all while earning **badges** for achievements.

---

## 🌍 Overview

TrailBuddy was built as part of a **Capstone Project** for the *Northern Greenbelt Conservation Authority (NGCA)*.  
The app addresses real-world challenges such as hikers getting lost or losing network access by offering **offline maps**, **GPS tracking**, and **emergency support** even in remote areas.

---

## 🚀 Key Features

- 🗺 **Offline Map Navigation** – Explore trails without internet using cached map tiles.  
- 📍 **Real-Time GPS Tracking** – Get your exact location on the map.  
- 📷 **Trail Condition Reports** – Submit issues or photos about trail hazards.  
- 🏅 **Badge Rewards** – Earn badges for completed trails, reports, and safe hikes.  
- 🚨 **Emergency Notifications (SOS)** – Sends alert with your coordinates in one tap.  
- 📡 **Cross-Platform Support** – Runs on both Android and Windows.  

---

## 🧰 Tech Stack

| Technology | Purpose |
|-------------|----------|
| **Flutter / Dart** | Cross-platform development |
| **flutter_map** | Map visualization |
| **flutter_map_tile_caching** | Offline map caching |
| **geolocator** | Location and GPS access |
| **flutter_local_notifications** | Alerts and SOS |
| **OpenStreetMap API** | Open data map provider |
| **Visual Studio Code** | Primary IDE |

---

## ⚙️ Installation & Setup

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/Inderpreeet/TrailBuddy.git
cd TrailBuddy

2️⃣ Install Dependencies
flutter pub get

3️⃣ Configure Android Permissions

Open android/app/src/main/AndroidManifest.xml and ensure these permissions are added:

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

4️⃣ Request Runtime Location Permissions

Add this in your Dart file:

LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}

5️⃣ Run the App
flutter run -d <device_id>

6️⃣ Build APK for Testing
flutter build apk --debug


Feature	Description
🗺 Offline Map	Cached trail maps with GPS marker
📍 GPS Tracking	Real-time position updates
🚨 Emergency Alert	Sends instant SOS message
🏅 Badges Page	Displays earned and upcoming badges
🎯 Future Enhancements

🤖 AI-driven route suggestions

🌦 Weather integration & air-quality alerts

⌚ Smartwatch compatibility

☁️ Cloud sync for reports & progress

💬 Community chat for hikers

👩‍💻 Author

Inderpreet Kaur
Mobile Application Development Program – Cambrian College
📅 Capstone Project (2025)
🔗 GitHub Profile

📜 License

This project is intended for educational and demonstration purposes.
All map data © OpenStreetMap Contributors
.
