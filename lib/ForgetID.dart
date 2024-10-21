import 'package:d_sai/Common/AppBarAlt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'Common/AppBar.dart';
import 'Common/Drawer.dart';
import 'Common/Footer.dart';
import 'HomePage.dart';

class ForgetID extends StatefulWidget {
  const ForgetID({Key? key}) : super(key: key);

  @override
  _ForgetIDState createState() => _ForgetIDState();
}

class _ForgetIDState extends State<ForgetID> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false; // Loading state
  double _opacity = 0.0;
@override  
@override
void initState() {
      Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
  super.initState();
  
}
  // Function to retrieve user ID based on email
  Future<void> _retrieveUserId() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your email address.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final url = 'https://dsaiqrbackend.vercel.app/api/v1/users/forget-user-id';
    final body = jsonEncode({
      "email": email,
      "url": "https://dsaiqrbackend.vercel.app" // Default URL if not provided
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Email sent successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Clear the email field
        emailController.clear();
      } else {
        Fluttertoast.showToast(
          msg: "Failed to send email. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "An error occurred: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen size for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;

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
child: SafeArea(
  child: Scaffold(
        // appBar: DSAiAppBar(),
        // drawer: const DSAiDrawer(),
        backgroundColor: Colors.white,
        body: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 500),
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
              Column(
                children: [
                  DSAiAppBar2(context: context),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Top icon/logo
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset('assets/logo.png'),
                            ),
                  
                            // Main Form Container
                            Container(
                              width: screenWidth < 600 ? screenWidth * 0.9 : 400, // Responsive width
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Forgot User ID',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00B884),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Enter your email address to retrieve your User ID.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                  
                                  // Email Input Field
                                  TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      hintText: 'you@example.com',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                  
                                  // Retrieve User ID Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _retrieveUserId,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple, // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        child: _isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                'Retrieve User ID',
                                                style: TextStyle(color: Colors.white, fontSize: 16),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                  
                                  // Back Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (Route<dynamic> route) => false, // Remove all routes
                    );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF00B884)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        child: Text(
                                          'Back',
                                          style: TextStyle(color: Color(0xFF00B884)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                  
                            // Footer Text and Contact Us Button
                            DSAiFooter(context),
                          ],
                        ),
                      ),
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
