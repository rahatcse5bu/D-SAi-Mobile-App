import 'package:d_sai/Login.dart';
import 'package:d_sai/UserDashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:http/http.dart' as http; // Import for making API requests
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for JSON decoding
import 'Common/AppBar.dart';
import 'Common/Drawer.dart';
import 'HomePage.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isLoading = false;
  bool isAccessed = false;
  List<String> validIds = []; // List to store valid IDs from API response

  @override
  void initState() {
    super.initState();
    _loadCheckInStatusAndRedirect();
    // _fetchValidIds(); // Fetch valid IDs from the API on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start the QR scanner after the first frame completes
      _startQRScanner();
    });
  }

  @override
  void dispose() {
    // Dispose any controllers if needed
    super.dispose();
  }

  Future<void> _loadCheckInStatusAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool('isCheckedIn') ?? false;

    final checkInTimeStr = prefs.getString('checkInTime');
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

  Future<void> checkAccessKey(String accessId) async {
    final String apiUrl =
        'https://dsaiqrbackend.vercel.app/api/v1/access-links/check-qr/$accessId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            isAccessed = data['success']
                as bool; // Return the value of "data" field, which is a boolean
          });
        } else {
          setState(() {
            isAccessed =
                false; // Return the value of "data" field, which is a boolean
          });
        }
      } else {
        // Handle non-200 responses here
        throw Exception(
            'Failed to check access key. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error occurred while checking access key: $e');
      setState(() {
        isAccessed = false; // Return false
      });
    }
  }

  // Function to fetch valid IDs from the API
  // Future<void> _fetchValidIds() async {
  //   const String apiUrl =
  //       'https://dsaiqrbackend.vercel.app/api/v1/access-links/access-ids';
  //   try {
  //     debugPrint("Fetching data from API...");
  //     final response = await http.get(Uri.parse(apiUrl));
  //     debugPrint("API response received: ${response.statusCode}");

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       debugPrint("Parsed data: $data");

  //       if (data['success'] == true) {
  //         // Extract IDs from the response
  //         validIds = (data['data'] as List)
  //             .map((item) => item['ID'].toString())
  //             .toList();
  //         debugPrint('Fetched valid IDs: $validIds');
  //       } else {
  //         _safeShowErrorDialog('Failed to fetch valid IDs from the server.');
  //       }
  //     } else {
  //       _safeShowErrorDialog('Failed to connect to the server.');
  //     }
  //   } catch (e) {
  //     debugPrint("Error caught: $e");
  //     _safeShowErrorDialog('Error fetching data: $e');
  //   }
  // }

  // Function to start QR scanning automatically
  void _startQRScanner() async {
    if (!mounted) return; // Ensure the widget is still mounted
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AiBarcodeScanner(
            onDispose: () {
              debugPrint("QR Code scanner disposed!");
            },
            bottomSheetBuilder: (context, controller) {
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                color: Colors.transparent,
                child: const Text(
                  "D-SAi QR Scanner",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF00B884),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              );
            },
            // hideGalleryButton: true,
            // hideGalleryIcon: true,
            appBarBuilder: (context, controller) {
              return DSAiAppBar();
            },
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (BarcodeCapture capture) async {
              try {
                final String? scannedValue = capture.barcodes.first.rawValue;
                debugPrint("QR Code scanned: $scannedValue");

                if (scannedValue != null) {
                  Navigator.of(context)
                      .pop(scannedValue); // Pass the scanned value back
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Handle the scanned result after pop completes
                    _handleScannedResult(scannedValue);
                  });
                } else {
                  debugPrint("No scanned value found.");
                  _safeShowErrorDialog("No QR code detected.");
                }
              } catch (e) {
                debugPrint("Error in onDetect: $e");
                _safeShowErrorDialog("Error processing QR code.");
              }
            },
          ),
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
        // Start the QR scanner after the first frame completes
        _startQRScanner();
      });

      if (result == null) {
        debugPrint("No QR code result received.");
      }
    } catch (e) {
      debugPrint("Error in _startQRScanner: $e");
      _safeShowErrorDialog("Failed to start QR scanner.");
    }
  }

  // New method to handle the scanned result and perform further navigation
  Future<void> _handleScannedResult(String result) async {
    debugPrint("Handling scanned result: $result");

    if (result.isNotEmpty) {
      final keyId =
          _extractKeyIdFromUrl(result); // Extract the key ID from the URL
      debugPrint("Extracted key ID: $keyId");

      // Normalize IDs: trim whitespace and convert to lowercase for consistent matching
      final normalizedKeyId = keyId?.trim().toLowerCase();
      final normalizedValidIds =
          validIds.map((id) => id.trim().toLowerCase()).toList();

      debugPrint("Normalized Key ID: $normalizedKeyId");
      debugPrint("Normalized Valid IDs: $normalizedValidIds");
      await checkAccessKey(normalizedKeyId!);
      if (normalizedKeyId != null && isAccessed) {
        // If the key ID matches an ID from the API response
        final extractedText = _extractTextAfterQRCode(result);
        debugPrint(
            "Navigating to WebView with URL: $result and Title: $extractedText");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Ensure navigator is not locked
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Login(
                  accessKey: normalizedKeyId,
                  company: extractedText,
                ),
              ),
            );
          }
        });
      } else {
        debugPrint("Scanned QR code does not match any valid IDs.");
        // Show error dialog with the comparable IDs
        // _safeShowErrorDialog(
        //     'The scanned QR code does not belong to D-SAi.\n\n'
        //     'Extracted Key ID: $normalizedKeyId\n\n'
        //     'Valid IDs: ${normalizedValidIds.join(", ")}');
        _safeShowErrorDialog('The scanned QR code does not belong to D-SAi.\n\n'
            'Extracted Key ID: $normalizedKeyId');
      }
    } else {
      debugPrint("No result or result is not a string.");
      _safeShowErrorDialog("Invalid QR code result.");
    }
  }

  // Function to extract the key ID from the QR code URL
  String? _extractKeyIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last; // Assuming the key ID is always the last segment
      }
    } catch (e) {
      debugPrint("Error parsing URL: $e");
    }
    return null;
  }

  // Function to extract the text after /qr-code/ from the scanned URL
  String _extractTextAfterQRCode(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final qrIndex = segments.indexOf('login');
      if (qrIndex != -1 && qrIndex + 1 < segments.length) {
        return segments[qrIndex + 1]; // Extract the text after /qr-code/
      }
    } catch (e) {
      debugPrint("Error extracting text from URL: $e");
    }
    return 'Unknown';
  }

  // Safe function to show an error dialog with context check
  void _safeShowErrorDialog(String message) {
    if (!mounted) return; // Ensure the widget is still mounted
    debugPrint("Showing error dialog: $message");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a delay to ensure navigator is not locked
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            // Added to handle potentially long messages
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Start the QR scanner after the first frame completes
                  _startQRScanner();
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
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
          drawer: DSAiDrawer(),
          resizeToAvoidBottomInset:
              true, // Ensures the layout adapts to the keyboard
          body: Center(
            child: isLoading
                ? const CircularProgressIndicator() // Show loading indicator while scanning
                : const Text(
                    'Scanning QR Code...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ));
  }
}
