import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting and parsing
import 'package:shared_preferences/shared_preferences.dart';
import 'Common/AppBar.dart';
import 'Common/Drawer.dart';
import 'Common/EmployeeInfoCard.dart';
import 'Common/Footer.dart';
import 'HomePage.dart';

class EmployeeDashboard extends StatefulWidget {
  final String employeeName;
  final String position;
  final String employeeId;

  const EmployeeDashboard({
    Key? key,
    required this.employeeName,
    required this.position,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  List<dynamic> _workHistory = [];
  List<dynamic> _filteredWorkHistory = [];
  bool _isLoading = true;
  String _filterCompanyName = '';
  DateTimeRange? _selectedDateRange;
  double _opacity = 0.0;

  int _currentPage = 1; // Current page
  int _totalPages = 1; // Total pages from API response
  final int _limit = 12; // Limit of items per page

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    _fetchWorkHistory();
  }

  // Fetch work history data from the API with pagination
  Future<void> _fetchWorkHistory() async {
    setState(() {
      _isLoading = true; // Show loading indicator when fetching
    });
    try {
      final String apiUrl =
          'https://dsaiqrbackend.vercel.app/api/v1/employee-views/all-employee-views-by-eid/${widget.employeeId}?page=$_currentPage&limit=$_limit';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            _workHistory = data['data'];
            _filteredWorkHistory = _workHistory;
            _totalPages = data['totalPages']; // Set total pages
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('workHistory', json.encode(_workHistory));
        } else {
          _showError('Invalid response format from server');
        }
      } else {
        _showError(
            'Failed to load work history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator after fetching
      });
    }
  }

  // Function to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Format time for Check-in and Check-out
  String formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Invalid Time'; // Handling null value
    try {
      final DateTime time = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Format date for readability
  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Invalid Date'; // Handling null value
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Show date range picker
  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _isLoading = true; // Show loading animation during filtering
      });
      _applyFilters();
    }
  }

  // Apply filters based on selected date range and company name
  void _applyFilters() {
    List<dynamic> filteredData = _workHistory;

    // Filter by company name if provided
    if (_filterCompanyName.isNotEmpty) {
      filteredData = filteredData
          .where((work) => work['companyName']
              .toString()
              .toLowerCase()
              .contains(_filterCompanyName.toLowerCase()))
          .toList();
    }

    // Filter by date range if selected
    if (_selectedDateRange != null) {
      filteredData = filteredData.where((work) {
        DateTime workDate = DateTime.parse(work['date']);
        return workDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            workDate
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredWorkHistory = filteredData;
      _isLoading = false; // Hide loading animation after filtering
    });
  }

  // Build the table header row
  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildHeaderCell('Date'),
        _buildHeaderCell('Check In'),
        _buildHeaderCell('Check Out'),
        _buildHeaderCell('Break Time'),
        _buildHeaderCell('Total Time'),
        _buildHeaderCell('Address'),
      ],
    );
  }

  // Build header cells
  Widget _buildHeaderCell(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      color: const Color(0xFF00B884),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Function to create table cells
  Widget _buildTableCell(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 248, 248, 248)),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Navigate to the next page
  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _fetchWorkHistory();
      });
    }
  }

  // Navigate to the previous page
  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _fetchWorkHistory();
      });
    }
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
        appBar: DSAiAppBar(title:widget.employeeName),
        // drawer: const DSAiDrawer(),
        body: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              SizedBox(height: 10),
              EmployeeCard(
                employeeName: widget.employeeName,
                position: widget.position,
                employeeId: widget.employeeId,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: "Search by Company Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _filterCompanyName = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      label: const Text("Filter", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B884),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            defaultColumnWidth: IntrinsicColumnWidth(),
                            border: TableBorder.all(color: Colors.grey),
                            children: [
                              _buildTableHeader(),
                              ..._filteredWorkHistory.map((work) {
                                return TableRow(
                                  children: [
                                    _buildTableCell(formatDate(work['date'])),
                                    _buildTableCell(formatTime(work['checkedIn'])),
                                    _buildTableCell(formatTime(work['checkedOut'])),
                                    _buildTableCell(work['breakTime'] ?? 'N/A'),
                                    _buildTableCell(work['totalTime'] ?? 'N/A'),
                                    _buildTableCell(work['address'] ?? 'N/A'),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              _buildPaginationControls(), // Pagination controls here
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
