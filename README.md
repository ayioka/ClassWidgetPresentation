# Flutter Interactive viewer demo widget


**InteractiveViewer** is a Flutter widget that wraps any child with built-in pinch-to-zoom and pan gestures, no third-party packages required.


*Run Instructions*

Requirements: Flutter 3.0+ · Dart 3.0+

# 1. Clone or download this project
git clone https://github.com/your-username/interactive_viewer_demo.git
cd interactive_viewer_demo

# 2. Get dependencies (none beyond Flutter SDK)
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# Key Attributes

***minScale / maxScale***
Controls how far the user can zoom out and in. In this demo the map can be zoomed from 40% down to 500% up — giving plenty of room to explore city detail without losing the full map view.

***boundaryMargin***
Adds extra panning space beyond the child's edges. Without it the map snaps back the moment its border reaches the screen edge. Set to EdgeInsets.all(300) here so you can pan fluidly to any corner.

A **TransformationController** that gives you full programmatic read/write access to the current zoom and pan matrix. Used in this demo to power the +/−/Reset buttons and the animated fly-to-city feature via Matrix4Tween

# BREAKDOWN

lib/
└── main.dart          # Complete single-file implementation

pubspec.yaml           # Project manifest (no extra dependencies)

README.md              # This file

<img width="586" height="1011" alt="image" src="https://github.com/user-attachments/assets/c42dc32f-2056-4ef1-b585-246bad77d228" />


