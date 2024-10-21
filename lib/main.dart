import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Required for SystemNavigator.pop()
import 'package:geolocator/geolocator.dart'; // For checking location services

import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions(); // Request permissions before running the app
  runApp(const MyApp());
}

// Function to request necessary permissions
Future<void> requestPermissions() async {
  // Request location permission
  PermissionStatus locationStatus = await Permission.location.status;
  PermissionStatus cameraStatus = await Permission.camera.status;

  if (locationStatus.isDenied ||
      cameraStatus.isDenied ||
      locationStatus.isRestricted ||
      cameraStatus.isRestricted) {
    // Request both permissions if not already granted
    Map<Permission, PermissionStatus> statuses =
        await [Permission.location, Permission.camera].request();

    if (statuses[Permission.location]!.isGranted &&
        statuses[Permission.camera]!.isGranted) {
      // If granted, proceed with location services check
      await _checkLocationServices();
    } else {
      // If permission is denied, exit the app
      _showPermissionDeniedDialog();
    }
  } else if (locationStatus.isGranted && cameraStatus.isGranted) {
    // If already granted, proceed with location services check
    await _checkLocationServices();
  }
}

// Function to check if location services are enabled
Future<void> _checkLocationServices() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // If location services are not enabled, prompt the user to turn them on
    _showLocationServicesDialog();
  }
}

// Show a dialog to enable location services
void _showLocationServicesDialog() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content: const Text(
            'Location services are required for this app. Please turn on location services in your device settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              // Open device location settings
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
              await _checkLocationServices(); // Re-check after returning from settings
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator
                  .pop(); // Exit the app if the user doesn't enable location
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  });
}

// Show a dialog and exit the app if permission is denied
void _showPermissionDeniedDialog() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
            'Camera and location permissions are required for this app.'),
        actions: [
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // Exit the app if permission is denied
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  });
}

// Global navigator key to access the context before the app starts
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return GetMaterialApp(
      navigatorKey: navigatorKey, // Set the global navigator key
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      // home: const Login(company: '', accessKey: '',),
      // home: const GiveFeedback(),
      // home: const HomePage(),
      // home: const SignUpPage(),
      // home: const ForgetID(),
      // home: const UserDashboard(),
      // home: const SuccessScreen(),
    );});
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0; // To store the progress value (0 to 1)
  int _percentage = 0; // To store the percentage (1 to 100)

  @override
  void initState() {
    super.initState();
    _startLoading(); // Start loading
  }

  // Function to handle progress and navigation
  void _startLoading() {
    // Set a timer to increase the progress over time
    Timer.periodic(const Duration(milliseconds: 20), (Timer timer) {
      if (_percentage == 100) {
        timer.cancel(); // Cancel the timer when loading is complete
        _navigateToQRScanner(); // Navigate to next screen
      } else {
        setState(() {
          _percentage += 1; // Increase percentage by 1
          _progress = _percentage / 100; // Calculate progress as a fraction
        });
      }
    });
  }

  // Function to navigate to the next page after the progress completes
  void _navigateToQRScanner() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(), // Navigate to HomePage
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/D_SAi_Logo.png', // Logo at the center of the splash screen
              width: 110,
              height: 110,
            ),
            const SizedBox(height: 20),
            
            // // Loading bar (linear progress indicator)
            // Container(
            //   padding: EdgeInsetsDirectional.symmetric(horizontal: 40),
            //   child: LinearProgressIndicator(
            //     value: _progress, // Set the progress value (0.0 to 1.0)
            //     minHeight: 8.0, // Set the height of the loading bar
            //     backgroundColor: Colors.grey[300],
            //     color: const Color(0xFF00B884), // Progress bar color
            //   ),
            // ),
            // const SizedBox(height: 20),

            // // Display the percentage as text
            // Text(
            //   '$_percentage%', // Show the percentage (1 to 100)
            //   style: const TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFF00B884),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}