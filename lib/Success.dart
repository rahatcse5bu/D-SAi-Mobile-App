import 'package:d_sai/Common/AppBar.dart';
import 'package:flutter/material.dart';

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
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
  canPop: false,
  onPopInvokedWithResult  : (didPop, result) {
     // Pop all routes and navigate to HomePage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false, // Remove all routes
        );
        // return result.; // Indicate that the pop is handled
  } ,
child: Scaffold(
  
            appBar: DSAiAppBar(),
      drawer: DSAiDrawer(),
      backgroundColor: Colors.grey[200],
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(milliseconds: 500),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3FCEC), // Light green background color
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green[700], // Dark green color for the checkmark
                ),
                const SizedBox(height: 10),
                const Text(
                  'Task Completed Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087F23), // Dark green color for the title
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
        ),
      ),
    ));
  }
}
