import 'package:d_sai/Common/AppBar.dart';
import 'package:d_sai/Common/AppBarAlt.dart';
import 'package:d_sai/DashboardLogin.dart';
import 'package:d_sai/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Common/Drawer.dart';
import 'HomePage.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  double _opacity = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });

        // Navigate to the next screen after a 2-second delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardLogin()),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // Pop all routes and navigate to HomePage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false, // Remove all routes
          );
          // return result.; // Indicate that the pop is handled
        },
        child: Scaffold(
          // appBar: DSAiAppBar(),
          // drawer: const DSAiDrawer(),
          backgroundColor: Colors.grey[200],
          body: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 500),
            child: Center(
              child: Stack(
               
                children: [
                          // Fixed top background image
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/top.png',
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 180.h, // Adjust the height for your design
                      ),
                    ),
                    // Fixed bottom background image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/bottom.png',
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        // height: 200, // Adjust the height for your design
                      ),
                    ),
                    DSAiAppBar2(context: context),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE3FCEC), // Light green background color
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 50,
                              color: Colors
                                  .green[700], // Dark green color for the checkmark
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Task Completed Successfully!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    Color(0xFF087F23), // Dark green color for the title
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Congratulations! You’ve successfully completed your task.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
