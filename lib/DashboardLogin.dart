import 'dart:convert';
import 'package:flutter/material.dart';
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

      print("body: $body");

      final response = await _loginUserWithoutQR(body);

      print("status code====>>> ${response.statusCode}");
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
        position: user['contractorPosition'] ?? 'No Position', // Changed to 'contractorPosition'
        employeeId: user['eid'] ?? 'No Employee ID',
      ),
    ),
  );
} else {
  _showError("Invalid response format. No Client or Employee ID found.");
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
      resizeToAvoidBottomInset: true, // Ensures the layout adapts to the keyboard
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox( // Ensure the height is constrained properly
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.asset('assets/logo.png'),
                          const SizedBox(height: 20),
                          const Text(
                            "D-SAi QR CODE System",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Lottie.asset(
                            'assets/lotties/loginAnimation.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back,",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Step into your team and unleash your optimal performance during every work hour.",
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B884),
                        ),
                        onPressed: _handleDashboardLogin,
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    DSAiFooter(), // Footer widget
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: 
                  CircularProgressIndicator(
                    color: const Color(0xFF00B884),
                  ),
               
            ),
        ],
      ),
    ));
  }
}
