import 'dart:io';

import 'package:d_sai/Common/AppBar.dart';
import 'package:d_sai/Common/Footer.dart';
import 'package:d_sai/DashboardLogin.dart';
import 'package:d_sai/ForgetID.dart';
import 'package:d_sai/QRScanner.dart';
import 'package:d_sai/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Common/Drawer.dart';
import 'UserDashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    _loadCheckInStatusAndRedirect();
  }

  Future<void> _loadCheckInStatusAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool('isCheckedIn') ?? false;

    final accessKey = prefs.getString('accessKey');

    if (isCheckedIn == true && accessKey != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserDashboard(
                    accessId: accessKey!,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen size for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          bool shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit) {
            // Exit the app
            if (Platform.isAndroid) {
              SystemNavigator.pop(); // Minimize app on Android
            } else if (Platform.isIOS) {
              exit(0); // Close app for iOS
            }
          }
          // Return null to prevent popping the page unless the user confirms
          return null;
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            // appBar: DSAiAppBar(),
            // drawer: const DSAiDrawer(),
            body: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/top.png',
                        fit: BoxFit.cover,
                        width: screenWidth,
                      )),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/bottom.png',
                        fit: BoxFit.cover,
                        width: screenWidth,
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Logo Section
                  
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: 100.w, // Adjust width based on your design
                              // height: 100, // Adjust height based on your design
                            ),
                             SizedBox(height: 10.h),
                            const Text(
                              'D-SAi QR Code System',
                              style: TextStyle(
                                fontSize: 20, // Adjusted to smaller font size
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00B884),
                              ),
                            ),
                          ],
                        ),
                      ),
                  
                       SizedBox(height: 30.h),
                  
                      // Buttons Section with Lottie animations
                      Container(
                        width: screenWidth < 600 ? screenWidth * 0.9 : 400,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                // Login Button with Lottie animation
                                _buildActionButton(
                                  context: context,
                                  title: 'Login',
                                  lottieFile:
                                      'assets/lotties/loginAnimation.json',
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardLogin(),
                                      ),
                                    );
                                  },
                                ),
                                // Sign Up Button with Lottie animation
                                _buildActionButton(
                                  context: context,
                                  title: 'Sign Up',
                                  lottieFile: 'assets/lotties/signup.json',
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                             SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                // QR Code Scan Button with Lottie animation
                                _buildActionButton(
                                  context: context,
                                  title: 'QR Code Scan',
                                  lottieFile: 'assets/lotties/scan-qr.json',
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const QRScannerPage(),
                                      ),
                                    );
                                  },
                                ),
                                // Forget Password Button with Lottie animation
                                _buildActionButton(
                                  context: context,
                                  title: 'Forget Password',
                                  lottieFile: 'assets/lotties/forget-id.json',
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgetID(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  
                       SizedBox(height: 20.h),
                  
                      // Footer Text
                      DSAiFooter(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Show a confirmation dialog when the user presses the back button
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you really want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // User chose not to exit
                child: Text('No'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // User chose to exit
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; // Return false if the dialog is dismissed without selecting an option
  }

  // Helper function to create buttons with Lottie animations and text
  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String lottieFile,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 150.w, // Width for each button
      height: 160.h, // Height for each button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White background for button
          shadowColor: const Color.fromARGB(255, 235, 231, 231)
              .withOpacity(0.2), // Light shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          side: const BorderSide(
              color: Color.fromARGB(255, 235, 231, 231), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              lottieFile,
              width: 100.w, // Adjust the size as per your design
              // height: 125,
            ),
             SizedBox(height: 10.h),
            Text(
              title,
              style:  TextStyle(
                fontSize: 13.sp, // Text size
                color: Colors.black, // Text color
                fontWeight: FontWeight.bold, // Text weight
              ),
            ),
            SizedBox(
              height: 8.h,
            )
          ],
        ),
      ),
    );
  }
}
