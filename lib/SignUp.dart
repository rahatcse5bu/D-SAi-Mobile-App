import 'package:d_sai/Common/AppBar.dart';
import 'package:d_sai/Common/AppBarAlt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'Common/Drawer.dart';
import 'HomePage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  XFile? _clientImage;
  XFile? _employeeImage;
  bool isLoading = false;
  // Controllers for Client and Employee forms
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController clientPhoneNumberController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mailIdController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController bankDetailsController = TextEditingController();
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  // Function to pick image
  Future<void> _pickImage(bool isClient) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (isClient) {
        _clientImage = image;
      } else {
        _employeeImage = image;
      }
    });
  }

  // Function to handle Client Sign-Up
  Future<void> _submitClientSignUp() async {
    final url = Uri.parse('https://dsaiqrbackend.vercel.app/api/v1/clients/');
    final payload = {
      'companyName': companyNameController.text,
      'name': nameController.text,
      'registrationNumber': registrationNumberController.text,
      'number': clientPhoneNumberController.text,
      'address': addressController.text,
      'restaurantMailId': mailIdController.text,
    };
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload));
      final msgBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Client Signed up successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _clearClientForm();
        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: "$msgBody['message']",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Function to handle Employee Sign-Up
  Future<void> _submitEmployeeSignUp() async {
    final url = Uri.parse('https://dsaiqrbackend.vercel.app/api/v1/employees/');
    final payload = {
      'contractorFullName': fullNameController.text,
      'contractorPosition': positionController.text,
      'email': emailController.text,
      'number': phoneNumberController.text,
      'bankDetails': bankDetailsController.text,
    };
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload));
      final msgBody = jsonDecode(response.body);

      print(" employee body ${jsonEncode(payload)}");
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Employee signed up successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        setState(() {
          isLoading = false;
        });
        _clearEmployeeForm();
      } else {
        Fluttertoast.showToast(
          msg: "${msgBody['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to clear Client form fields
  void _clearClientForm() {
    companyNameController.clear();
    nameController.clear();
    registrationNumberController.clear();
    clientPhoneNumberController.clear();
    addressController.clear();
    mailIdController.clear();
    _clientImage = null;
  }

  // Function to clear Employee form fields
  void _clearEmployeeForm() {
    fullNameController.clear();
    positionController.clear();
    emailController.clear();
    phoneNumberController.clear();
    bankDetailsController.clear();
    _employeeImage = null;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / 2;

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
        child: SafeArea(
          child: Scaffold(
            // appBar: DSAiAppBar(),
            // drawer: DSAiDrawer(),
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
                    // height: 180.h, // Adjust the height for your design
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
                       SizedBox(height: 30.h,),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        // padding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutExpo,
                          tween: Tween<double>(begin: 0, end: 1),
                          builder:
                              (BuildContext context, double opacity, Widget? child) {
                            return TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF00B884),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle:  TextStyle(
                                  fontSize: 13.sp, fontWeight: FontWeight.bold),
                              unselectedLabelStyle:  TextStyle(fontSize: 13.sp),
                              physics:
                                  const BouncingScrollPhysics(), // Smoothens the swipe
                              tabs: [
                                Tab(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 1200),
                                    curve: Curves.easeOutExpo,
                                    width: tabWidth,
                                    alignment: Alignment.center,
                                    child: const Text('Client'),
                                  ),
                                ),
                                Tab(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 1200),
                                    curve: Curves.easeOutExpo,
                                    width: tabWidth,
                                    alignment: Alignment.center,
                                    child: const Text('Employee'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildClientSignUp(),
                            _buildEmployeeSignUp(),
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

  // Client Sign-Up Form
  Widget _buildClientSignUp() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
         
               _buildTextField('Name', nameController),
             SizedBox(height: 10.h),
              _buildTextField('Company Name', companyNameController),
               SizedBox(height: 10.h),
            _buildTextField(
                'Registration Number', registrationNumberController),
               SizedBox(height: 10.h),
            _buildTextField(
                'Phone Number', clientPhoneNumberController),
               SizedBox(height: 10.h),
            _buildTextField('Address', addressController),
             SizedBox(height: 10.h),
            _buildTextField('Email ID', mailIdController),
           SizedBox(height: 10.h),
            // _buildPictureUpload(isClient: true),
            SizedBox(height: 10.h),
            _buildSubmitButton('Sign Up as Client', _submitClientSignUp),
          ],
        ),
      ),
    );
  }

  // Employee Sign-Up Form
  Widget _buildEmployeeSignUp() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Full Name', fullNameController),
              SizedBox(height: 10.h),
            _buildTextField('Position', positionController),
           SizedBox(height: 10.h),
            _buildTextField('Email', emailController),
              SizedBox(height: 10.h),
            _buildTextField('Phone Number', phoneNumberController),
            SizedBox(height: 10.h),
            _buildTextField('Bank Account Details', bankDetailsController),
            SizedBox(height: 10.h),
            // _buildPictureUpload(isClient: false),
            SizedBox(height: 10.h),
            _buildSubmitButton('Sign Up as Employee', _submitEmployeeSignUp),
          ],
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Picture Upload Widget for Client and Employee
  Widget _buildPictureUpload({required bool isClient}) {
    XFile? image = isClient ? _clientImage : _employeeImage;
    return image == null
        ? Container(
            width: double.maxFinite,
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(isClient),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Upload Picture',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B884),
              ),
            ),
          )
        : Column(
            children: [
              Image.file(
                File(image.path),
                height: 150.h,
              ),
               SizedBox(height: 10.h),
              TextButton(
                onPressed: () => _pickImage(isClient),
                child: const Text(
                  'Change Picture',
                  style: TextStyle(color: Color(0xFF00B884)),
                ),
              ),
            ],
          );
  }

  // Reusable Submit Button
  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B884),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: [
                isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        text,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
