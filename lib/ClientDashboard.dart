import 'dart:convert';
import 'package:d_sai/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting and parsing
import 'package:fluttertoast/fluttertoast.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchEmployeeViews(); // Fetch data when the page loads
  }

  // Fetch data from new API
  Future<void> _fetchEmployeeViews() async {
    try {
      final String apiUrl =
          'https://dsaiqrbackend.vercel.app/api/v1/clients/client-details/${widget.cid}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _employeeViews = data['data'];
        });
      } else {
        _showError(
            'Failed to load employee views. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Error handling
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: kErrorColor))),
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
      appBar: DSAiAppBar(title: "Client Dashboard - ${widget.userName}"),
      drawer: DSAiDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kLoadingIndicatorColor))
          : _employeeViews.isEmpty
              ? const Center(
                  child: Text("No employee data found.",
                      style: TextStyle(fontSize: 16)))
              : Column(
                  children: [
                    Container(
                      child: CompanyCard(
                        companyData: {
                          'companyName': _employeeViews[0]['companyName'],
                          'companyAddress': _employeeViews[0]['companyAddress'],
                          'companyMailId': _employeeViews[0]['companyMailId'],
                          'companyNumber': _employeeViews[0]['companyNumber'],
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
                  ],
                ),
    ));
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
      // Add a row for the date
      rows.add(DataRow(cells: [
        DataCell(Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        // DataCell(Container()), // Empty cells to fill in the row
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
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
        const SizedBox(width: 10), // Add some space between the image and the text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              view['contractorFullName'] ?? 'N/A',
              
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4), // Add spacing between name and role
            Text( view['employeePosition'] ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
