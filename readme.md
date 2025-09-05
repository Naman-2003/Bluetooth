# Bluetooth
Bluetooth

BLE Demo Flutter App

A Flutter demo app using FlutterBluePlus to scan, connect, read, write, and receive notifications from Bluetooth Low Energy (BLE) devices.

Features

Scan for nearby BLE devices

Connect / disconnect to devices

Discover services and characteristics

Read and write characteristic values

Enable notifications for characteristic changes

Auto-reconnect on disconnection

Scan timeout and manual stop

Connection status indicator

Requirements

Real Android device (BLE doesn’t work on emulator)

Bluetooth turned ON

Location services enabled (Android 10+)

Installation

Clone the repository

Add dependencies in pubspec.yaml:

dependencies:
flutter:
sdk: flutter
flutter_blue_plus: ^x.x.x


Run flutter pub get

Usage

Open the app on a real device

Press Scan for Devices to search for BLE devices

Select a device and press Connect

Discover services and interact with characteristics:

Read → Read value

Write → Send data

Notify → Receive real-time updates

Press Disconnect to disconnect

Notes

Scanning automatically stops after 5 seconds, or you can press Stop Scan

Connection errors (like Android error 133) are retried automatically

Notifications and read/write operations are handled with proper error feedback

Use connectionState to monitor device status and implement auto-reconnect


Screenshots

<p float="left">
<img src="https://github.com/user-attachments/assets/b2209b8e-a65e-4b54-a155-270689d2d676" width="150" />
<img src="https://github.com/user-attachments/assets/2687f978-e1b1-4024-b990-a2921fa7a4de" width="150" />
<img src="https://github.com/user-attachments/assets/08ea45f4-3c9e-41af-a06c-89b7caf97edb" width="150" />
<img src="https://github.com/user-attachments/assets/ef77d99d-f007-48d4-98df-c2bb8941a126" width="150" />
</p>
