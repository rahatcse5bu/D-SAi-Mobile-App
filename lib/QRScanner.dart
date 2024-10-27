import 'package:d_sai/Login.dart';
import 'package:d_sai/UserDashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http; // Import for making API requests
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for JSON decoding
import 'Common/AppBar.dart';
import 'Common/AppBarAlt.dart';
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
  bool _scanningFinished = false; // To ensure QR scanner doesn't restart
  List<String> validIds = []; // List to store valid IDs from API response
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    _loadCheckInStatusAndRedirect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scanningFinished) {
        // Start the QR scanner after the first frame completes
        _startQRScanner();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCheckInStatusAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool('isCheckedIn') ?? false;
    final accessKey = prefs.getString('accessKey') ?? '';

    if (isCheckedIn == true && accessKey != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserDashboard(accessId: accessKey!),
        ),
      );
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
            isAccessed = data['data'] as bool; // Access validation
          });
        } else {
          setState(() {
            isAccessed = false;
          });
        }
      } else {
        setState(() {
          isAccessed = false;
        });
        throw Exception(
            'Failed to check access key. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while checking access key: $e');
      setState(() {
        isAccessed = false;
      });
    }
  }

  void _startQRScanner() async {
    if (!mounted || _scanningFinished) return;
    setState(() {
      isLoading = true;
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
            // appBarBuilder: (context, controller) {
            //   return DSAiAppBar2(context: context);
            // },
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            hideGalleryButton: true,
            hideGalleryIcon: true,
            onDetect: (BarcodeCapture capture) async {
              try {
                // Check if barcodes list is not empty before accessing it
                if (capture.barcodes.isNotEmpty) {
                  final String? scannedValue = capture.barcodes.first.rawValue;
                  debugPrint("QR Code scanned: $scannedValue");

                  if (scannedValue != null) {
                    Navigator.of(context).pop(scannedValue); // Pass scanned value
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _handleScannedResult(scannedValue);
                    });
                  } else {
                    debugPrint("No scanned value found.");
                    _safeShowErrorDialog("No QR code detected.");
                  }
                } else {
                  debugPrint("Barcode list is empty.");
                  _safeShowErrorDialog("No barcodes detected.");
                }
              } catch (e) {
                debugPrint("Error in onDetect: $e");
                _safeShowErrorDialog("Error processing QR code.");
              }
            },
          ),
        ),
      );

      setState(() {
        isLoading = false;
      });

      if (result == null) {
        debugPrint("No QR code result received.");
      }
    } catch (e) {
      debugPrint("Error in _startQRScanner: $e");
      _safeShowErrorDialog("Failed to start QR scanner.");
    }
  }

  Future<void> _handleScannedResult(String result) async {
    if (_scanningFinished) return; // Ensure this only runs once
    setState(() {
      _scanningFinished = true;
    });

    debugPrint("Handling scanned result: $result");

    if (result.isNotEmpty) {
       Map<String, String> queryParams = extractQueryParamsFromUrl(result);
      final keyId = queryParams['accessId'];
      final companyName = queryParams['companyName'];
      final cid = queryParams['cid'];
      debugPrint("Extracted key ID: $keyId");
      debugPrint("Extracted company name: $companyName");

      if (keyId != null && companyName != null) {
        await checkAccessKey(keyId);
        if (keyId.isNotEmpty && isAccessed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Login(
                accessKey: "${keyId}",
                company: "${companyName}",
                cid: "${cid}",
              ),
            ),
          );
        } else {
          _safeShowErrorDialog("The scanned QR code does not belong to D-SAi.KeyID: $keyId, result ${result} Company Name: $companyName, isAccessed: $isAccessed");
        }
      } else {
        _safeShowErrorDialog(
            "The scanned QR code does not belong to D-SAi. KeyID: $keyId, Company Name: $companyName, isAccessed: $isAccessed");
      }
    } else {
      _safeShowErrorDialog("No valid QR code result.");
    }
  }

  String? _extractCompanyNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty && segments.length >= 4) {
        return segments[2]; // Assuming the company name is the 3rd segment (index 2)
      }
    } catch (e) {
      debugPrint("Error parsing URL for company name: $e");
    }
    return null;
  }

  String? _extractKeyIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last; // Assuming the key ID is the last segment
      print("keyyyyy: $segments.last");
      }
    } catch (e) {
      debugPrint("Error parsing URL for key ID: $e");
    }
    return null;
  }

  void _safeShowErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
// String extractCidFromUrl(String url) {
//   // Parse the URL
//   Uri uri = Uri.parse(url);

//   // Extract the 'cid' query parameter
//   String? cid = uri.queryParameters['cid'];

//   // Print or use the extracted cid value
//   if (cid != null) {
//        print('Extracted CID: $cid');
//     return cid.toString();
 
//   } else {
//     print('CID not found in the URL.');
//     return '';
    
//   }
// }
Map<String, String> extractQueryParamsFromUrl(String url) {
  // Parse the URL
  Uri uri = Uri.parse(url);

  // Extract the query parameters 'cid', 'accessId', and 'companyName'
  String? cid = uri.queryParameters['cid'];
  String? accessId = uri.queryParameters['accessId'];
  String? companyName = uri.queryParameters['companyName'];

  // Return a map with the extracted values
  return {
    'cid': cid ?? '', // Use empty string if cid is null
    'accessId': accessId ?? '', // Use empty string if accessId is null
    'companyName': companyName ?? '', // Use empty string if companyName is null
  };
}


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      },
      child: SafeArea(
        child: Scaffold(
          // appBar: DSAiAppBar(),
          // drawer: DSAiDrawer(),
          resizeToAvoidBottomInset: true,
          body: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 500),
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
                  
                    Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                  'Scanning QR Code...',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
