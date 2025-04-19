# 🧰 Flutter Remote Debug UI

A lightweight Flutter Desktop tool to manage remote debugging sessions via SSH, ADB, and `flutter attach`.  
Perfect for developers working with remote Android devices, embedded boards, or LAN-connected iOS simulators.

---

## ✨ Features

- 🔗 **Establish SSH tunnels** to remote Flutter devices
- 🚀 **Run `flutter run` remotely** via SSH
- 🪄 **Start `flutter attach`** with a single click
- 📡 **ADB TCP port forwarding** for Android devices (local or remote)
- 🌐 **Open Flutter DevTools** from the UI
- 🧠 **Saved hosts dropdown** for quick access
- 🧾 **Live logs view** in the interface

---

## 📸 Screenshots

*(Add UI screenshots here, e.g., `assets/screenshot1.png`)*

---

## 🖥️ Supported Platforms

- ✅ macOS
- ✅ Windows
- ✅ Linux

> Make sure Flutter Desktop support is enabled:

```bash
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

---

## ⚙️ Requirements

- 🧩 Flutter installed on both local **and** remote machines
- 🔐 SSH access to the remote device (e.g., Raspberry Pi, Linux server)
- 📱 Android device available via USB or ADB-over-WiFi
- 🛠 The app must be in debug mode (not release-signed)

---

## 🚀 Getting Started

1. Clone the project:

```bash
git clone https://github.com/your-username/flutter-remote-debug-ui.git
cd flutter-remote-debug-ui
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run on your platform:

```bash
flutter run -d macos      # or windows, linux
```

---

## 🔌 Usage

1. Enter SSH credentials, ports, and remote host
2. Select a saved host from the dropdown
3. Click **Connect & Attach**
4. Optionally use **Flutter Run (Remote)**, **ADB Forward**, or **DevTools**

---

## 📂 Project Structure

```text
lib/
├── main.dart             # Main UI with SSH and Attach logic
├── widgets/              # (optional) reusable UI components
assets/
├── screenshot1.png       # UI screenshots for the README
README.md
```

---

## 🧠 Possible Enhancements

- ✅ Load host configs from a local file
- ⌨️ Hotkey support for quick commands
- 💾 SSH/attach session history
- 🛠 SSH key picker + advanced auth options

---

## 📜 License

MIT License – free to use, share, and contribute.

---

## 🙌 Contributions

Pull requests and issues are welcome!  
If you have tips for remote Flutter workflows (e.g., ADB tricks, SSH aliases), share them in the discussions!
