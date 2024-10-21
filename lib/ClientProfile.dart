import 'package:d_sai/Common/AppBar.dart';
import 'package:d_sai/Common/Footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Common/AppBarAlt.dart';
import 'Common/Drawer.dart';
import 'HomePage.dart';

class ClientDashboard extends StatefulWidget {
  final String userName;
  final String date;
  final String companyName;
  final String address;
  final String bankDetail;
  final String referencePerson;
  final String restaurantMailId;
  final String dashboardLink;
  final String qrCodeLink;

  ClientDashboard({
    required this.userName,
    required this.date,
    required this.companyName,
    required this.address,
    required this.bankDetail,
    required this.referencePerson,
    required this.restaurantMailId,
    required this.dashboardLink,
    required this.qrCodeLink,
  });

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
    double _opacity = 0.0;
      @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in after 500ms
      });
    });
    super.initState();
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
          // appBar: DSAiAppBar(),
          // drawer: DSAiDrawer(),
          resizeToAvoidBottomInset:
              false, // Prevents resizing when the keyboard appears
          body: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 500),
            child: Center(
              child: Stack(
                children: [
                  //Fixed top background image
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
                    SingleChildScrollView(
                        child: Column(
              children: [
                // Top icon/logo
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset("assets/logo.png"),
                ),
              
                // Client Info Section
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B884),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                          SizedBox(width: 8),
                          Text(
                            'Date:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '9/16/2024', // Replace with the actual date
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.business, 'Company Name:', widget.companyName),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.location_on, 'Address:', widget.address),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.account_balance, 'Bank Detail - Payment:', widget.bankDetail),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.person, 'Reference Person:', widget.referencePerson),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.email, 'Restaurant Mail ID:', widget.restaurantMailId),
                      const SizedBox(height: 20),
              
                      // Dashboard and QR Code Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLinkButton('Dashboard Link', widget.dashboardLink),
                          _buildLinkButton('QR Code Link', widget.qrCodeLink),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              
                // Footer Text and Contact Us Button
                         DSAiFooter(context),
              ],
                        ),
                      )]),
            ),),
      ));
    
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkButton(String text, String url) {
    return InkWell(
      onTap: () {
        // Add logic to open the link
      },
      child: Row(
        children: [
          const Icon(Icons.link, color: Color(0xFF00B884)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF00B884),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
