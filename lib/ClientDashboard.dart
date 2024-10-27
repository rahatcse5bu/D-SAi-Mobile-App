import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:d_sai/Common/AppBarAlt.dart';
import 'package:d_sai/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart'; // For date formatting and parsing
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'Common/AppBar.dart';
import 'Common/CompanyInfoCard.dart';
import 'Common/Drawer.dart';

const kAppBarColor = Color(0xFF00B884);
const kTextColorWhite = Colors.white;
const kCellPadding = EdgeInsets.all(8.0);
const kHeaderBackgroundColor = Color(0xFF00B884);
const kCellBackgroundColor = Colors.white;
const kBorderColor = Color.fromARGB(255, 248, 248, 248);
const kErrorColor = Colors.red;
const kLoadingIndicatorColor = Color(0xFF00B884);

class ClientDashboard extends StatefulWidget {
  final String userName;
  final String companyName;
  final String cid;

  const ClientDashboard({
    Key? key,
    required this.userName,
    required this.companyName,
    required this.cid,
  }) : super(key: key);

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  List<dynamic> _employeeViews = [];
Map<String, dynamic> _clientDetails = {}; // Update declaration

  bool _isLoading = true;
  double _opacity = 0.0;
  late Uint8List _imageFile;
  int _currentPage = 1; // Current page
  int _totalPages = 1; // Total number of pages
  final int _limit = 12; // Limit of items per page
  late String uniqueAccessKey;
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    super.initState();
    // Generate a unique access key
    uniqueAccessKey = Uuid().v4(); // Generates a unique UUID (v4)
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });

    _fetchEmployeeViews(); // Fetch data when the page loads
  }

  // Fetch data from new API with pagination
  Future<void> _fetchEmployeeViews() async {
    setState(() {
      _isLoading = true; // Show loading indicator when fetching
    });
    try {
      // final String apiUrl =
      //     'https://dsaiqrbackend.vercel.app/api/v1/clients/client-details/${widget.cid}?page=$_currentPage&limit=$_limit';
      // final response = await http.get(Uri.parse(apiUrl));
// debugPrint("${response.body}");
 final String apiUrl =
          'https://dsaiqrbackend.vercel.app/api/v2/clients/client-details/${widget.cid}?page=$_currentPage&limit=$_limit';
      final response = await http.get(Uri.parse(apiUrl));
// debugPrint("${response.body}");
// https://dsaiqrbackend.vercel.app/api/v2/clients/client-details/C3298192
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _employeeViews = data['data'];
          _clientDetails= data;
          _totalPages = data['pagination']['pages']; // Set total pages
        });
      } else {
        _showError(
            'Failed to load employee views. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator after fetching
      });
    }
  }

  // Error handling
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: kErrorColor))),
    );
  }

  // Navigate to the next page
  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _fetchEmployeeViews();
      });
    }
  }

  // Navigate to the previous page
  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _fetchEmployeeViews();
      });
    }
  }

  Future<bool> _postAccessLink(String accessId) async {
    final String apiUrl =
        'https://dsaiqrbackend.vercel.app/api/v1/access-links';
    final Map<String, dynamic> body = {
      'accessId': accessId,
      'accessType': 'not-accessed',
      'companyName': widget.companyName,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Handle success response
        print('Access link posted successfully: ${response.body}');
        return true;
      } else {
        // Handle error response
        print(
            'Failed to post access link. Status code: ${response.statusCode}');
        _showError(
            'Failed to post access link. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error posting access link: $e');
      _showError('An error occurred while posting access link: $e');
      return false;
    }
  }

  Future<void> _downloadQRImage() async {
    Navigator.pop(context);
    try {
      final Uint8List? capturedImage = await screenshotController.capture();

      if (capturedImage == null) {
        throw Exception('Failed to capture screenshot');
      }

      setState(() {
        _imageFile = capturedImage;
      });

      final qrValidationString =
          'http://www.d-sai.com/qr/login/${widget.companyName}/$uniqueAccessKey/?cid=${widget.cid}';

      final qrPainter = QrPainter(
        data: qrValidationString,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black, // Set your foreground color
        emptyColor: Colors.white, // Set your background color
      );

      final byteData =
          await qrPainter.toImageData(300, format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      // Ask for permission in a loop

      if (await Permission.manageExternalStorage.request().isGranted) {
        final result = await ImageGallerySaverPlus.saveImage(
            // pngBytes,
            _imageFile,
            name: "qr_code_$uniqueAccessKey");
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR Code image saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image')),
          );
        }
      } else {
        // Permission denied; show a Snackbar and give an option to try again
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Storage permission denied. Please allow access to save the QR Code.'),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () async {
                final PermissionStatus status =
                    await Permission.storage.request();
                if (status.isGranted) {
                } else if (status.isDenied) {
                  // Permission denied. Show a message and optionally ask again.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Storage permission denied. Please allow access to save images.')),
                  );
                } else if (status.isPermanentlyDenied) {
                  // Permission is permanently denied, you can open app settings.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Storage permission is permanently denied. Please enable it in app settings.'),
                      action: SnackBarAction(
                        label: 'Settings',
                        onPressed: () {
                          openAppSettings();
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showError('An error occurred while downloading the QR code: $e');
    }
  }

Future<void> _showQRDialog() async {
  // Check for existing QR code
  final existingQRCodeFile = await _getExistingQRCode(uniqueAccessKey);

  if (existingQRCodeFile != null) {
    // Show the existing QR code
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Stored QR Code",
              style: TextStyle(fontSize: 16.sp, color: Color(0xFF10A7AE)),
            ),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Color(0xFF10A7AE),
              borderRadius: BorderRadius.circular(10),
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Scan For Task",
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(20.sp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.file(existingQRCodeFile, height: 200, width: 200),
                  ),
                  SizedBox(height: 5.h),
                  Column(
                    children: [
                      Text(
                        widget.companyName,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "D-Sai | www.d-sai.com",
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
         ElevatedButton(
              onPressed: () {
                // Share the QR code image file
                Share.shareXFiles([XFile(existingQRCodeFile.path)], text: 'Here is the QR code for ${widget.companyName}');
              },
              child: Text("Share QR Code", style: TextStyle(color: Colors.blue, fontSize: 13.sp)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close", style: TextStyle(color: Colors.red, fontSize: 13.sp)),
            ),
          ],
        );
      },
    );
  } else {
    // If QR code file is not found, generate a new QR code and display it
    final bool isAccessKeyPosted = await _postAccessLink(uniqueAccessKey);

    if (isAccessKeyPosted) {
      showDialog(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Generated QR Code",
                style: TextStyle(fontSize: 16.sp, color: Color(0xFF10A7AE)),
              ),
            ),
            content: Screenshot(
              controller: screenshotController,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF10A7AE),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Scan For Task", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                      SizedBox(height: 8.h),
                      QrImageView(
                        data: 'http://www.d-sai.com/qr/login/?companyName=${widget.companyName}&accessId=${uniqueAccessKey}&cid=${widget.cid}',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      SizedBox(height: 5.h),
                      Column(
                        children: [
                          Text(
                            widget.companyName,
                            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "D-Sai | www.d-sai.com",
                            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final Uint8List? capturedImage = await screenshotController.capture();
                  if (capturedImage != null) {
                    await _saveQRCodeLocally(capturedImage, uniqueAccessKey);
                    _downloadQRImage(); // Download QR code image after saving it locally
                  }
                },
                child: Text("Download QR Code", style: TextStyle(color: Colors.blue, fontSize: 13.sp)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close", style: TextStyle(color: Colors.red, fontSize: 13.sp)),
              ),
            ],
          );
        },
      );
    } else {
      _showError("Failed to post access link. Please try again.");
    }
  }
}

Future<String> _getQRFilePath(String uniqueKey) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/qr_code_$uniqueKey.png';
}

Future<File?> _getExistingQRCode(String uniqueAccessKey) async {
  final qrFilePath = await _getQRFilePath(uniqueAccessKey);
  final qrFile = File(qrFilePath);
  
  if (await qrFile.exists()) {
    return qrFile; // Return the file if it exists
  } else {
    return null; // Return null if the file doesn't exist
  }
}
Future<void> _saveQRCodeLocally(Uint8List qrImageBytes, String uniqueAccessKey) async {
  final qrFilePath = await _getQRFilePath(uniqueAccessKey);
  final qrFile = File(qrFilePath);
  await qrFile.writeAsBytes(qrImageBytes); // Save the QR code as an image
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
        },
        child: SafeArea(
          child: Scaffold(
            // appBar: DSAiAppBar(title: " ${widget.userName}"),
            // drawer: DSAiDrawer(),
            body: Stack(
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
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: kLoadingIndicatorColor))
                    : _clientDetails.isEmpty
                        ? AnimatedOpacity(
                            opacity: _opacity,
                            duration: const Duration(milliseconds: 500),
                            child: const Center(
                                child: Text("No client data found.",
                                    style: TextStyle(fontSize: 16))),
                          )
                        : AnimatedOpacity(
                            opacity: _opacity,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                DSAiAppBar2(context: context),
                                Container(
                                  child: CompanyCard(
                                    companyData: {
                                      'companyName': _clientDetails['companyName'],
                                      'companyAddress': _clientDetails['companyAddress'],
                                      'companyMailId': _clientDetails['companyMailId'],
                                      'companyNumber': _clientDetails['companyNumber'],
                                    },
                                    onShowQRDialog: _showQRDialog,
                                  ),
                                ),
                               if(_employeeViews.isNotEmpty) Expanded(
                                  child: SingleChildScrollView(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: _createColumns(),
                                        rows: _createGroupedRows(),
                                      ),
                                    ),
                                  ),
                                ),
                               if(_employeeViews.isNotEmpty) const SizedBox(height: 10),
                             if(_employeeViews.isNotEmpty)   _buildPaginationControls(), // Add pagination controls
                              if(_employeeViews.isNotEmpty)  const SizedBox(height: 10),
                              if(_employeeViews.isEmpty)  Center(
                                child: SizedBox(
                                  height: 400.h,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("No data found.",
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
              ],
            ),
          ),
        ));
  }

  // Build pagination controls
  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _currentPage > 1 ? _previousPage : null,
          child: Text('Previous'),
        ),
        Text('Page $_currentPage of $_totalPages'),
        ElevatedButton(
          onPressed: _currentPage < _totalPages ? _nextPage : null,
          child: Text('Next'),
        ),
      ],
    );
  }

  // Group employee data by date
  Map<String, List<dynamic>> _groupByDate() {
    Map<String, List<dynamic>> groupedData = {};

    for (var view in _employeeViews) {
      String date = formatDate(view['checkedIn']);

      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }

      groupedData[date]!.add(view);
    }

    return groupedData;
  }

  // Create table rows with dates grouped
  List<DataRow> _createGroupedRows() {
    Map<String, List<dynamic>> groupedData = _groupByDate();
    List<DataRow> rows = [];

    groupedData.forEach((date, views) {
      // Add a row for the date, filling up all 13 columns with empty cells
      rows.add(DataRow(cells: [
        DataCell(Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        // Add empty cells for the remaining 12 columns
        ...List.generate(11, (_) => DataCell(Container())),
      ]));

      // Add rows for each employee under the date
      for (var view in views) {
        rows.add(DataRow(cells: [
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/employee_profile.png'),
                    radius: 20, // Adjust the size of the profile image
                  ),
                  const SizedBox(width: 10), // Add space between image and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        view['contractorFullName'] ?? 'N/A',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                          height: 4), // Spacing between name and role
                      Text(view['employeePosition'] ?? 'N/A',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DataCell(Text(formatDate(view['checkedIn']))), //date 
          DataCell(Text(formatTime(view['checkedIn']))),
          DataCell(Text(formatTime(view['checkedOut']))),
          DataCell(Text(view['breakTime'] ?? 'N/A')),
          DataCell(Text(view['totalTime'] ?? 'N/A')),
          DataCell(Text((view['latitude'] ?? 0.0).toString())),
          DataCell(Text((view['longitude'] ?? 0.0).toString())),
          // DataCell(Text((view['employeeRate'] ?? 0).toString())),
          DataCell(Text((view['restaurantRate'] ?? 0).toString())),
          DataCell(Text(view['companyAddress'] ?? 'N/A')),
          DataCell(Text((view['address'] ?? "N/A").toString())),
          DataCell(Text(view['accessId'] ?? 'N/A')),
        ]));
      }
    });

    return rows;
  }

  // Create table columns
  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
          label: Text(
        'Employee',
      )),
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Check In')),
      const DataColumn(label: Text('Check Out')),
      const DataColumn(label: Text('Break Time')),
      const DataColumn(label: Text('Total Time')),
      const DataColumn(label: Text('Latitude')),
      const DataColumn(label: Text('Longitude')),
      // const DataColumn(label: Text('Employee Rate')),
      const DataColumn(label: Text('Restaurant Rate')),
      const DataColumn(label: Text('Company Address')),
      const DataColumn(label: Text('Address')),
      const DataColumn(label: Text('Access ID')),
    ];
  }

  // Format date for readability
  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Invalid Date';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format time for Check-in and Check-out
  String formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Invalid Time';
    try {
      final DateTime time = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return 'Invalid Time';
    }
  }
}
