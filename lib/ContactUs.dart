import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'Common/AppBar.dart';
import 'Common/Drawer.dart';
import 'Common/Footer.dart';
import 'HomePage.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();
  bool _isLoading = false; // Loading state

  // Function to submit feedback
  Future<void> _submitFeedback() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final feedback = feedbackController.text.trim();

    if (name.isEmpty || email.isEmpty || feedback.isEmpty) {
      Fluttertoast.showToast(
        msg: "All fields are required.",
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

    final url = 'https://dsaiqrbackend.vercel.app/api/v1/users/contact-us';
    final body = jsonEncode({
      'name': name,
      'email': email,
      'message': feedback,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Your Query submitted successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Clear form fields after success
        nameController.clear();
        emailController.clear();
        feedbackController.clear();
      } else {
        Fluttertoast.showToast(
          msg: "Failed to submit info. Please try again.",
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
          appBar: DSAiAppBar(),
          // drawer: const DSAiDrawer(),
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth < 600
                    ? screenWidth * 0.9
                    : 400, // Responsive width
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
                    // Top icon/logo
                    Image.asset('assets/logo_alt.png'),
                    const SizedBox(height: 5),
                    const Text(
                      'Contact Form',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B884),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Input
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Your name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Email Input
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Feedback Input
                    TextFormField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        hintText: 'Your Message Here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Back and Submit Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                              (Route<dynamic> route) =>
                                  false, // Remove all routes
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        Flexible(
                            child: SizedBox(
                          width: 5,
                        )),
                        ElevatedButton(
                          onPressed: _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00B884),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Submit',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Footer Text
                    //  DSAiFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
