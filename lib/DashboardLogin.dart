import 'dart:convert';
import 'dart:developer';
import 'package:d_sai/Common/AppBarAlt.dart';
import 'package:d_sai/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Common/AppBar.dart';
import 'Common/Drawer.dart';
import 'Common/Footer.dart';
import 'EmployeeDashboard.dart';
import 'HomePage.dart';
import 'Success.dart'; // Assuming you have a success screen
import 'ClientDashboard.dart'; // Assuming you have a ClientDashboard
import 'UserDashboard.dart'; // Assuming you have a UserDashboard

class DashboardLogin extends StatefulWidget {
  const DashboardLogin({super.key});

  @override
  State<DashboardLogin> createState() => _DashboardLoginState();
}

class _DashboardLoginState extends State<DashboardLogin> {
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false; // State to show loading indicator
  double _opacity = 0.0;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    super.initState();
  }

  // Function to handle DashboardLogin
  Future<void> _handleDashboardLogin() async {
    String userId = _userIdController.text.trim().toUpperCase();

    if (userId.isEmpty) {
      _showError("Please enter your User ID.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Prepare API payload (Only userId is needed)
      final body = {
        "userId": userId,
      };

      print("bodyy: $body");

      final response = await _loginUserWithoutQR(body);

      print("status code===!!=>>> ${response.statusCode}");
      print("response====>>> ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success']) {
          // Show success toast message
          Fluttertoast.showToast(
            msg: "Login successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          log("login data=> ${json.encode(data['data'])}");
          // Optionally, you can store the user data here in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', json.encode(data['data']));

          // Redirect based on whether the user is a client or an employee
          final user = data['data'];
          if (user.containsKey('cid')) {
            // Client login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClientDashboard(
                  userName: user['name'] ?? '',
                  cid: user['cid'] ?? '',
                  companyName: user['companyName'] ?? 'Unknown Company',
                ),
              ),
            );
          } else if (user.containsKey('eid')) {
            // Employee login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeDashboard(
                  employeeName: user['contractorFullName'] ?? 'No Name',
                  position: user['contractorPosition'] ??
                      'No Position', // Changed to 'contractorPosition'
                  employeeId: user['eid'] ?? 'No Employee ID',
                ),
              ),
            );
          } else {
            _showError(
                "Invalid response format. No Client or Employee ID found.");
          }
        } else {
          _showError("Login failed: ${data['message']}");
        }
      } else {
        _showError("Failed to login. Please try again.");
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to make the login API request
  Future<http.Response> _loginUserWithoutQR(Map<String, dynamic> body) async {
    final String apiUrl =
        'https://dsaiqrbackend.vercel.app/api/v1/users/login-user-without-qr';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return response;
  }

  // Function to show error messages
  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // Pop all routes and navigate to HomePage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false, // Remove all routes
          );
          // return result.; // Indicate that the pop is handled
        },
        child: Scaffold(
          // appBar: DSAiAppBar(),
          // drawer: DSAiDrawer(),
          resizeToAvoidBottomInset:
              false, // Prevents resizing when the keyboard appears
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
                DSAiAppBar2(context: context),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 50.h),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    // Image.asset('assets/logo.png'),
                                    // SizedBox(height: 45.h),
                                    Text(
                                      "D-SAi QR Code System",
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Lottie.asset(
                                      'assets/lotties/loginAnimation.json',
                                      width: 150.w,
                                      height: 90.h,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15.h),
                              const Text(
                                "Welcome Back,",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              const Text(
                                "Step into your team and unleash your optimal performance during every work hour.",
                              ),
                              SizedBox(height: 10.h),
                              TextField(
                                controller: _userIdController,
                                decoration: InputDecoration(
                                  labelText: "User ID",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: "Enter your User ID",
                                ),
                              ),
                              SizedBox(height: 15.h),
                              SizedBox(
                                width: double.infinity,
                                height: 45.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B884),
                                  ),
                                  onPressed: _handleDashboardLogin,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Login",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Icon(
                                        Icons.login,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 45.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B884),
                                  ),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpPage()),
                                      (Route<dynamic> route) =>
                                          false, // Remove all routes
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Icon(
                                        Icons.person_add,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              DSAiFooter(context), // Footer widget
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFF00B884),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
