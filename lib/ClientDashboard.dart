import 'dart:convert';
import 'package:d_sai/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting and parsing
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
  bool _isLoading = true;
  double _opacity = 0.0;

  int _currentPage = 1; // Current page
  int _totalPages = 1;  // Total number of pages
  final int _limit = 12; // Limit of items per page

  @override
  void initState() {
    super.initState();
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
      final String apiUrl =
          'https://dsaiqrbackend.vercel.app/api/v1/clients/client-details/${widget.cid}?page=$_currentPage&limit=$_limit';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _employeeViews = data['data'];
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
        child: Scaffold(
          appBar: DSAiAppBar(title: " ${widget.userName}"),
          // drawer: DSAiDrawer(),
          body: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: kLoadingIndicatorColor))
              : _employeeViews.isEmpty
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
                          Container(
                            child: CompanyCard(
                              companyData: {
                                'companyName': _employeeViews[0]['companyName'],
                                'companyAddress': _employeeViews[0]
                                    ['companyAddress'],
                                'companyMailId': _employeeViews[0]
                                    ['companyMailId'],
                                'companyNumber': _employeeViews[0]
                                    ['companyNumber'],
                              },
                            ),
                          ),
                          Expanded(
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
                          const SizedBox(height: 10),
                          _buildPaginationControls(), // Add pagination controls
                          const SizedBox(height: 10),
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
      String date = formatDate(view['date']);

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
        ...List.generate(12, (_) => DataCell(Container())),
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
                      const SizedBox(height: 4), // Spacing between name and role
                      Text(view['employeePosition'] ?? 'N/A',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DataCell(Text(formatDate(view['date']))),
          DataCell(Text(formatTime(view['checkedIn']))),
          DataCell(Text(formatTime(view['checkedOut']))),
          DataCell(Text(view['breakTime'] ?? 'N/A')),
          DataCell(Text(view['totalTime'] ?? 'N/A')),
          DataCell(Text((view['latitude'] ?? 0.0).toString())),
          DataCell(Text((view['longitude'] ?? 0.0).toString())),
          DataCell(Text((view['employeeRate'] ?? 0).toString())),
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
      const DataColumn(label: Text('Employee Rate')),
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
