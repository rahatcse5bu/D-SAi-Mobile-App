import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'Common/AppBar.dart';
import 'Common/AppBarAlt.dart';
import 'Common/Drawer.dart';
import 'Common/Footer.dart';
import 'HomePage.dart';
import 'Success.dart';

class UserDashboard extends StatefulWidget {
  final String accessId;


  const UserDashboard({super.key, required this.accessId,});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  double _sliderPosition = 0.0; // Position of the slider
  bool _isCheckedIn = false; // To track if the user has checked in
  bool _isCheckedOut = false; // To track if the user has checked out
  Timer? _timer; // Timer for counting the time after check-in
  Duration _elapsedTime = Duration.zero; // Time elapsed since check-in
  DateTime? _checkInTime; // Track check-in time
  DateTime? _checkOutTime; // Track check-out time
  int selectedHours = 0; // Variable to store input hours
  int selectedMinutes = 0; // Variable to store input minutes

  // User profile data
  String userName = '';
  String userId = '';
  String companyName = '';
  RxDouble mainWidth= Get.width.obs;
  String referencePerson = '';
  //opacity for animation
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    print("Received accessId: ${widget.accessId}");
    _loadUserProfileData(); // Load user profile data from local storage
    _loadCheckInStatus(); // Load check-in status and elapsed time
  }

  // Function to load user profile data from SharedPreferences
  Future<void> _loadUserProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null && userData.isNotEmpty) {
      final user = json.decode(userData);

      if (user != null && user is Map) {
        setState(() {
          userName = user['contractorFullName'] ?? 'User Name';
          userId = user['eid'] ?? 'User ID';
          companyName = user['COMPANY NAME'] ?? 'Company Name';
          referencePerson = user['REFERNCE PERSON'] ?? 'Reference Person';
        });
      } else {
        print("User data is invalid.");
      }
    } else {
      print("No user data found.");
    }
  }

  // Load check-in status and elapsed time from local storage
  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Safely fetch and check check-in status
    final bool isCheckedIn = prefs.getBool('isCheckedIn') ?? false;

    // Safely fetch check-in time string
    final String? checkInTimeStr = prefs.getString('checkInTime');

    // Set slider position based on the check-in status
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth < 600 ? screenWidth * .7 : 320;

    if (isCheckedIn && !_isCheckedOut && checkInTimeStr != null) {
      try {
        setState(() {
          _isCheckedIn = true;
          _isCheckedOut = false;
          _checkInTime = DateTime.parse(checkInTimeStr); // Safely parse the date
          _sliderPosition = mainWidth.value - 60; // Set slider to the rightmost position
          _startTimer(); // Start the timer
        });
      } catch (e) {
        // If parsing fails or any other error occurs, log and reset values
        print("Error parsing check-in time: $e");
        setState(() {
          _isCheckedIn = false;
          _isCheckedOut = false;
          _sliderPosition = 0.0; // Reset slider to the leftmost position
        });
      }
    } else {
      setState(() {
        _isCheckedIn = false;
        _isCheckedOut = false;
        _sliderPosition = 0.0; // Set slider to the leftmost position
      });
    }
  }

  // Start the timer and update UI every second
  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_checkInTime != null) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_checkInTime!); // Update elapsed time
        });
      } else {
        // Handle null case (e.g., stop the timer)
        timer.cancel();
      }
    });
  }

  // Function to format the elapsed time into HH:MM:SS
  String _formatElapsedTime() {
    final hours = _elapsedTime.inHours.toString().padLeft(2, '0');
    final minutes = _elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // Function to handle drag updates for both check-in and check-out
  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _sliderPosition += details.delta.dx;
log("positoon: ${details.delta.dx}");
log("_sliderPosition: ${_sliderPosition}");
log("total width: ${Get.width-60}");
      // Ensure that the slider is within bounds
      // _sliderPosition = _sliderPosition.clamp(0.0, maxWidth-12);
      _sliderPosition = _sliderPosition.clamp(0.0, maxWidth-60);
    });
  }

  // Function to handle drag end for both check-in and check-out
  void _onDragEnd(double maxWidth) {
    if (!_isCheckedIn && _sliderPosition > maxWidth * 0.7) {
      _showCheckInConfirmation(maxWidth); // Check in when swiping right
    } else if (_isCheckedIn && _sliderPosition < maxWidth * 0.3) {
      _showBreakTimeDialog(maxWidth); // Show break dialog on check-out swipe left
    } else {
      // Reset slider if swipe was insufficient
      setState(() {
        _sliderPosition = _isCheckedIn ? maxWidth-60 : 0.0;
      });
    }
  }

  // Function to show check-in confirmation and start timer
  void _showCheckInConfirmation(double maxWidth) async {
    // Call the check-in API
    DateTime now = DateTime.now();
    var result = await checkInApiCall(now.toUtc().toIso8601String());

    if (result) {
      setState(() {
        _isCheckedIn = true;
        _sliderPosition = maxWidth-60; // Set slider to the right end
        _checkInTime =now.toUtc(); // Record check-in time
        _startTimer(); // Start the timer when checked in
        _saveCheckInStatus(true, _checkInTime!.toIso8601String());
        showToast("Checked in successfully!");
      });
    } else {
       setState(() {
      _sliderPosition = 0; // Set slider to the left end
       });
      showToast("Failed to check in.");
    }
  }

  // Save check-in status and check-in time to SharedPreferences
  Future<void> _saveCheckInStatus(bool isCheckedIn, String checkInTime) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool('isCheckedIn', isCheckedIn);
      await prefs.setBool('isCheckedOut', false);
      await prefs.setString('checkInTime', checkInTime);
      await prefs.setString('accessKey', widget.accessId);
      print("Check-in status saved successfully.");
    } catch (e) {
      print("Failed to save check-in status: $e");
    }
  }

  // Save check-out time to SharedPreferences
  Future<void> _saveCheckOutTime(String checkOutTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkOutTime', checkOutTime);
  }

  // Reset all states upon checkout and redirect to success page
  Future<void> _resetCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckedIn', false);
    await prefs.remove('checkInTime');
    await prefs.remove('checkOutTime');
    setState(() {
      _isCheckedIn = false;
      _elapsedTime = Duration.zero;
      _checkInTime = null;
      _checkOutTime = null;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SuccessScreen()),
    );
  }

  // Show the break time dialog box and process check-out
  void _showBreakTimeDialog(double maxWidth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BreakTimeDialog(
          onTimeSelected: (hours, minutes) async {
            setState(() {
              selectedHours = hours;
              selectedMinutes = minutes;
            });
            // Call the check-out API
            DateTime now = DateTime.now();
            String breakTime = '$selectedHours:$selectedMinutes';
            final prefs = await SharedPreferences.getInstance();
    final localCheckInTimeStr = prefs.getString('checkInTime') ?? '';
    // Parse the local check-in time (assumed to be stored in UTC ISO format)
  DateTime localCheckInTime = DateTime.parse(localCheckInTimeStr).toUtc();

  // Calculate the total worked time (difference between now and check-in)
  Duration workedDuration = now.difference(localCheckInTime);

  // Parse break time (HH:mm) into Duration
  List<String> breakTimeParts = breakTime.split(':');
  int breakHours = int.parse(breakTimeParts[0]);
  int breakMinutes = int.parse(breakTimeParts[1]);
  Duration breakDuration = Duration(hours: breakHours, minutes: breakMinutes);

  // Check if break time is greater than or equal to worked time
  if (breakDuration >= workedDuration) {
    // Show snackbar if break time exceeds or equals working time
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Break time can't be greater than working time")),
      
    );
    setState(() {
        _sliderPosition = mainWidth.value-60; // Reset to the right for retry
    });
  } 
  else{
            var result = await checkOutApiCall(now.toUtc().toIso8601String(), breakTime);

            if (result) {
              await prefs.setBool('isCheckedOut', true);
              setState(() {
                _isCheckedOut = true;
                _checkOutTime = now; // Record check-out time
              });
              _saveCheckOutTime(_checkOutTime!.toIso8601String());
              showToast("Checked out successfully!");
              _timer?.cancel(); // Stop the timer
              await _resetCheckInStatus(); // Reset the status and navigate to SuccessScreen
            } 
            
             else {
              // Reset slider to the right
              setState(() {
                _sliderPosition = mainWidth.value-60; // Reset to the right for retry
              });
              showToast("Failed to check out.");
            }
  }
          },
          onClose: () {
            // Reset the slider to the right without performing check-out
            setState(() {
              // _sliderPosition = maxWidth-12; // Reset slider back to the right
              _sliderPosition = mainWidth.value-60; // Reset slider back to the right
            });
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );
  }

  // Check-in API call
  Future<bool> checkInApiCall(String checkInTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckedOut', false);
    final localCheckInTime = prefs.getString('checkInTime') ?? checkInTime;
    final accessKey = prefs.getString('accessKey') ?? widget.accessId;

    final checkInUrl =
        'https://dsaiqrbackend.vercel.app/api/v1/employees/check-in';
    final body = jsonEncode({
      'accessId': accessKey,
      'checkedIn': localCheckInTime,
      'eid': userId,
    });
    print("check in payload $body");

    try {
      final response = await http.put(
        Uri.parse(checkInUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      setState(() {
        _isCheckedOut = false;
      });
      if (response.statusCode == 200) {
        print("checked in success ${response.body}");
        return true;
      } else {
        print("Failed to check in: ${response.body}");
        showToast("Failed to check in. Please try again later.");
        return false;
      }
    } catch (e) {
      setState(() {
        _isCheckedOut = false;
      });
      print("Error during check-in: $e");
      showToast("Error during check-in: $e");
      return false;
    }
  }

  // Check-out API call
  Future<bool> checkOutApiCall(String checkOutTime, String breakTime) async {
    final prefs = await SharedPreferences.getInstance();

    final accessKey = prefs.getString('accessKey') ?? widget.accessId;
    final checkOutUrl =
        'https://dsaiqrbackend.vercel.app/api/v1/employees/check-out';
    final body = jsonEncode({
      'accessId': accessKey,
      'checkedOut': checkOutTime,
      'breakTime': breakTime,
       'eid': userId,
    });
    print("checkout body $body");
    try {
      final response = await http.put(
        Uri.parse(checkOutUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print("response body ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          _isCheckedOut = true;
        });
        return true;
      } else {
        setState(() {
          _isCheckedOut = false;
        });
        print("Failed to check out: ${response.body}");
        showToast("Failed to check out. Please try again later.");
        return false;
      }
    } catch (e) {
      setState(() {
        _isCheckedOut = false;
      });
      print("Error during check-out: $e");
      showToast("Error during check-out: $e");
      return false;
    }
  }

  // Toast message function
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose of the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth < 600 ? screenWidth * .7 : 330;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // Pop all routes and navigate to HomePage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false, // Remove all routes
          );
        },
        child: SafeArea(
          child: Scaffold(
            // appBar: DSAiAppBar(),
            // drawer: const DSAiDrawer(),
            backgroundColor: Colors.white,
            body: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
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
                      SizedBox(height:15.h),
                    Center(
                      child: SingleChildScrollView(
                        child: Container(
                          // color: Colors.red, 
                          padding:  EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            
                            children: [
                           
                              // Top icon/logo
                              Container(
                                margin:  EdgeInsets.only(top: 20, bottom: 5.h),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                  // boxShadow: const [
                                  //   BoxShadow(
                                  //     color: Colors.black12,
                                  //     blurRadius: 10,
                                  //     spreadRadius: 2,
                                  //   ),
                                  // ],
                                ),
                                child: Lottie.asset('assets/lotties/shake-hand.json',
                                height: 50.h ,
                                width: 50.h ,
                                )
                                // Image.asset("assets/logo.png"),
                              ),
                              
                                              
                              // User Info Section
                              Container(
                                // width: screenWidth < 600 ? screenWidth * 1 : 380,
                                // padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  // color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(15),
                                  // boxShadow: [
                                  //   const BoxShadow(
                                  //     color: Colors.black12,
                                  //     blurRadius: 10,
                                  //     spreadRadius: 2,
                                  //   ),
                                  // ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      userName.toUpperCase(),
                                      style:  TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00B884),
                                      ),
                                    ),
                                     SizedBox(height: 10.h),
                                              
                                    // Profile Card
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.grey.shade300),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[300],
                                            child: userName.isNotEmpty
                                                ? Text(userName[0])
                                                : Icon(Icons.person),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'UID $userId',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                     SizedBox(height: 10.h),
                                    Stack(
                                      children: [
                                        Image.asset(
                                          'assets/clock.png',
                                          height: 120, 
                                              
                                        ),
                                        Positioned(
                                          top: 25,
                                          left: -45,
                                          child: Lottie.asset(
                                            'assets/lotties/clock.json',
                                            width: 200,
                                            height: 90,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                   
                                              
                                   SizedBox(height: 10.h),
                                              
                                    // Display countdown timer
                                    Visibility(
                                      visible: _isCheckedIn,
                                      child: Text(
                                        _formatElapsedTime(),
                                        style:  TextStyle(
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00B884),
                                        ),
                                      ),
                                    ),
                                     SizedBox(height: 15.h),
                                              
                                    // Custom Sliding Check-In / Check-Out Button
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                     
                                          mainWidth.value=constraints.maxWidth;
                                      
                                        // double parentWidth = constraints.maxWidth;
                                      return Container(
                                        // color: Colors.green,
                                        child: Stack(
                                          children: [
                                            // SizedBox(height: 200,),
                                            // Text("test ${constraints.maxWidth}"),
                                            Container(
                                              height: 60,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00B884)
                                                    .withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _isCheckedIn && !_isCheckedOut
                                                        ? ' Swipe to Check Out'
                                                        : ' Swipe to Check In',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Text("${mainWidth.value}"),
                                            Positioned(
                                              left: _sliderPosition,
                                              child: GestureDetector(
                                                onHorizontalDragUpdate: (details) =>
                                                    _onDragUpdate(details,mainWidth.value),
                                                onHorizontalDragEnd: (details) =>
                                                    _onDragEnd(mainWidth.value),
                                                child: AnimatedContainer(
                                                  duration:
                                                      const Duration(milliseconds: 100),
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF00B884),
                                                    borderRadius: BorderRadius.circular(50),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 5,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    _isCheckedIn && !_isCheckedOut
                                                        ? Icons.chevron_left
                                                        : Icons.chevron_right,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );},
                                    ),
                                  ],
                                ),
                              ),
                              // Footer
                              DSAiFooter(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

// Break Time Dialog Widget
class BreakTimeDialog extends StatefulWidget {
  final Function(int, int) onTimeSelected;
  final VoidCallback onClose;

  const BreakTimeDialog(
      {Key? key, required this.onTimeSelected, required this.onClose})
      : super(key: key);

  @override
  _BreakTimeDialogState createState() => _BreakTimeDialogState();
}

class _BreakTimeDialogState extends State<BreakTimeDialog> {
  int selectedHours = 0;
  int selectedMinutes = 0;

  void _submit() {
    _showConfirmationDialog(); // Show confirmation dialog before finalizing
  }

  // Show confirmation dialog before checking out
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: const Text('Are you sure you want to check out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                widget.onClose(); // Reset slider if Cancel is pressed
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onTimeSelected(selectedHours, selectedMinutes);
                Navigator.of(context).pop(); // Close the confirmation dialog
                Navigator.of(context).pop(); // Close the BreakTimeDialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 189, 14, 28),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: widget.onClose,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset("assets/lotties/cup.json", width: 80),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Placeholder for alignment
                    Expanded(
                      child: const Text(
                        'How much time you took for break?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                  
                    _buildTimeButton(0),
                    _buildTimeButton(15),
                    _buildTimeButton(30),
                    _buildTimeButton(45),
                    _buildTimeButton(60, label: '1 Hour'),
                    _buildTimeButton(75, label: '1.25 Hour'),
                    _buildTimeButton(90, label: '1.5 Hours'),
                    _buildTimeButton(105, label: '1.75 Hours'),
                    _buildTimeButton(120, label: '2 Hours'),
                    _buildTimeButton(180, label: '3 Hours'),
                    _buildTimeButton(240, label: '4 Hours'),
                  ],
                ),
                // const SizedBox(height: 15),
                // const Text('Or Input Manually',
                //     style: TextStyle(fontSize: 16, color: Colors.grey)),
                // const SizedBox(height: 15),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     _buildManualInputField(
                //         'Hour', (value) => selectedHours = int.parse(value)),
                //     const SizedBox(width: 10),
                //     _buildManualInputField(
                //         'Min', (value) => selectedMinutes = int.parse(value)),
                //   ],
                // ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B884),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    child: const Text('Submit',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(int minutes, {String? label}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHours = minutes ~/ 60;
          selectedMinutes = minutes % 60;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
          color: selectedHours * 60 + selectedMinutes == minutes
              ? Colors.yellow
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label ?? '$minutes Min',
          style: TextStyle(
            fontSize: 14,
            color: selectedHours * 60 + selectedMinutes == minutes
                ? Colors.black
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildManualInputField(String label, Function(String) onChanged) {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
