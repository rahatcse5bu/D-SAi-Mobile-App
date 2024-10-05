import 'package:d_sai/Common/AppBar.dart';
import 'package:d_sai/Common/Footer.dart';
import 'package:flutter/material.dart';

import 'Common/Drawer.dart';

class ClientDashboard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DSAiAppBar(title:companyName),
     
      drawer: DSAiDrawer(),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
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
                      userName,
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
                    _buildInfoRow(Icons.business, 'Company Name:', companyName),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on, 'Address:', address),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.account_balance, 'Bank Detail - Payment:', bankDetail),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.person, 'Reference Person:', referencePerson),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.email, 'Restaurant Mail ID:', restaurantMailId),
                    const SizedBox(height: 20),

                    // Dashboard and QR Code Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLinkButton('Dashboard Link', dashboardLink),
                        _buildLinkButton('QR Code Link', qrCodeLink),
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
        ),
      ),
    );
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
