import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// A utility class that handles window management for desktop platforms.
/// This class provides functionality to initialize and configure window properties
/// for Windows, Linux, and macOS applications.
class WindowHelper {
  /// Initializes the application window with specific configurations.
  /// This method should be called before runApp() in the main function.
  ///
  /// The initialization process includes:
  /// 1. Checking if the app runs on a desktop platform
  /// 2. Initializing the window manager
  /// 3. Setting up window properties (size, position, appearance)
  /// 4. Showing and focusing the window
  static Future<void> initializeWindow() async {
    // Skip initialization if not running on desktop platform
    if (!_isDesktopPlatform) return;

    // Ensure window manager is initialized
    await windowManager.ensureInitialized();

    // Configure window options
    WindowOptions windowOptions = const WindowOptions(
        title: 'Todo App', // Sets the window title
        size: Size(800, 800), // Initial window size
        minimumSize: Size(400, 500), // Minimum allowed window size
        center: true, // Centers window on screen
        backgroundColor: Colors.transparent, // Window background color
        skipTaskbar: false, // Show in taskbar
        titleBarStyle: TitleBarStyle.hidden, // Hides default title bar
        windowButtonVisibility: false);

    // Wait for the window to be ready and then show it
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show(); // Makes window visible
      await windowManager.focus(); // Brings window to front
    });
  }

  /// Private getter to determine if the current platform is desktop
  /// Returns true for Windows, Linux, or macOS
  static bool get _isDesktopPlatform =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Public getter to check if running on desktop platform
  /// This can be used throughout the app to implement platform-specific logic
  static bool get isDesktopPlatform => _isDesktopPlatform;
}

/// Additional Window Manager Methods Available:
/// - windowManager.setSize(Size size)          // Change window size
/// - windowManager.setMinimumSize(Size size)   // Set minimum window size
/// - windowManager.setMaximumSize(Size size)   // Set maximum window size
/// - windowManager.center()                    // Center window on screen
/// - windowManager.maximize()                  // Maximize window
/// - windowManager.minimize()                  // Minimize window
/// - windowManager.restore()                   // Restore window from maximized/minimized
/// - windowManager.close()                     // Close window
/// - windowManager.setTitle(String title)      // Change window title
/// - windowManager.setFullScreen(bool isFullScreen) // Toggle fullscreen
/// - windowManager.setBackgroundColor(Color color) // Change background color
/// - windowManager.setAlwaysOnTop(bool isAlwaysOnTop) // Set window always on top
/// - windowManager.setBrightness(Brightness brightness) // Set window brightness
/// - windowManager.setResizable(bool isResizable) // Set if window can be resized
/// - windowManager.setMovable(bool isMovable) // Set if window can be moved
/// - windowManager.setSkipTaskbar(bool skip) // Show/hide in taskbar
