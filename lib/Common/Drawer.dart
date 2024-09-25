import 'package:d_sai/DashboardLogin.dart';
import 'package:d_sai/ForgetID.dart';
import 'package:d_sai/HomePage.dart';
import 'package:d_sai/Login.dart';
import 'package:d_sai/QRScanner.dart';
import 'package:d_sai/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DSAiDrawer extends StatelessWidget {
  const DSAiDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header with Logo and Slogan
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 49, 87, 51), // Background color
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                ),
                const SizedBox(height: 10),
                // Slogan
                const Text(
                  'D-SAi QR Code Scanner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // List of Drawer Items with Animation

          _buildDrawerItem(
            icon: Icons.home,
            text: 'Home',
            onTap: () {
              Navigator.pop(context); // Closes the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.qr_code_scanner,
            text: 'Scan QR Code',
            onTap: () {
              Navigator.pop(context); // Closes the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()),
              );
            },
          ),

          _buildDrawerItem(
            icon: Icons.dashboard,
            text: 'Login to Dashboard',
            onTap: () {
              Navigator.pop(context); // Closes the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardLogin()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_add,
            text: 'Sign Up',
            onTap: () {
              Navigator.pop(context); // Closes the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.lock_open,
            text: 'Forget ID',
            onTap: () {
              Navigator.pop(context); // Closes the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgetID()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to create a ListTile with an icon and text
  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green[800],
        ),
        title: Text(text, style: TextStyle(fontSize: 16),),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 18), // Right arrow icon
        onTap: onTap,
      ),
    );
  }
}
