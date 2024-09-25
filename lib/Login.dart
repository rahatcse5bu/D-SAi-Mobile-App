import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'ClientProfile.dart';
import 'Common/AppBar.dart';
import 'Common/Drawer.dart';
import 'Common/Footer.dart';
import 'ForgetID.dart';
import 'GiveFeedback.dart';
import 'HomePage.dart';
import 'UserDashboard.dart';

class Login extends StatefulWidget {
  final String company;
  final String accessKey;

  const Login({super.key, required this.company, required this.accessKey});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false; // State to show loading indicator
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    _checkAndRequestLocationPermission(); // Request location permission when the screen loads
  }

  // Function to check and request location permissions
  Future<void> _checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError(
            'Location permission is required to continue. Please enable location access.');
      } else if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
      }
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission granted, continue with your logic
    }
  }

  // Function to handle login
  Future<void> _handleLogin() async {
    String userId = _userIdController.text.trim().toUpperCase();

    if (userId.isEmpty) {
      _showError("Please enter your User ID.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Get the user's location
      Position position = await _determinePosition();
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Get address from coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      String address =
          "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";

      // Prepare API payload
      final body = {
        "companyName": widget.company,
        "accessId": widget.accessKey,
        "userId": userId,
        "latitude": latitude,
        "longitude": longitude,
        "address": address
      };
      print("body:  $body");

      final response = await _loginUser(body);
      print("status code====>>> ${response.statusCode}");
      print("resposneeeeee ====>>> ${response}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Log API response

        if (data['success']) {
          final user = data['data'];
          print('user $user');

          // Store user data and location locally
          final prefs = await SharedPreferences.getInstance();
          // await prefs.setString('userData', json.encode(user));
          await prefs.setDouble('latitude', latitude);
          await prefs.setDouble('longitude', longitude);
          await prefs.setString('address', address);

          // Store the accessId (replace old one if present)
          await prefs.setString('accessId', widget.accessKey);

          // Determine whether it's a Client or Employee by checking if `cid` or `eid` exists
          if (user.containsKey('cid')) {
            // Navigate to Client Dashboard if `cid` exists
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ClientDashboard(
                  userName: user['name'] ?? '',
                  date:
                      '', // The date might be in the response, update as necessary
                  companyName: user['companyName'] ?? '',
                  address: user['address'] ?? '',
                  bankDetail: user['bankDetailPayment'] ?? '',
                  referencePerson: user['referencePerson'] ?? '',
                  restaurantMailId: user['restaurantMailId'] ?? '',
                  dashboardLink: user['dashboard'] ?? '',
                  qrCodeLink: user['qrCode'] ?? '',
                ),
              ),
            );
          } else if (user.containsKey('eid')) {
            //store only employee data
            await prefs.setString('userData', json.encode(user));
            // Navigate to Employee/User Dashboard if `eid` exists
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboard(
                  accessId: widget
                      .accessKey, // Pass accessId to the UserDashboard page
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
        _showError("Failed to login. ${json.decode(response.body)['message']}");
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
  Future<http.Response> _loginUser(Map<String, dynamic> body) async {
    final String apiUrl = 'https://dsaiqrbackend.vercel.app/api/v1/users/login';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return response;
  }

  // Function to determine the user's position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied.');
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Function to show permission dialog when permanently denied
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'This app needs location access to provide the service. Please grant location access in the settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Geolocator
                  .openAppSettings(); // Open app settings for the user to grant permission
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Function to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
          appBar: DSAiAppBar(title: "D-SAi: ${widget.company}"),
          drawer: DSAiDrawer(),
          resizeToAvoidBottomInset:
              true, // Ensures the layout adapts to the keyboard
          body: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 500),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    // Ensure the height is constrained properly
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 50),
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
                                  width: 150,
                                  height: 150,
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
                              onPressed: _handleLogin,
                              child: const Text(
                                "Login",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigate to ForgetID
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgetID(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forget User ID",
                                  style: TextStyle(
                                    color: Color(0xff00B884),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // TextButton(
                              //   onPressed: () {
                              //     // Navigate to Give Feedback
                              //     Navigator.pushReplacement(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => GiveFeedback(),
                              //       ),
                              //     );
                              //   },
                              //   child: const Text(
                              //     "Give Feedback",
                              //     style: TextStyle(
                              //       color: Colors.redAccent,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          // Text(
                          //     "Company: "),
                          DSAiFooter(), // Footer widget
                        ],
                      ),
                    ),
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
