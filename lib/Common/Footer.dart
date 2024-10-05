import 'package:d_sai/HomePage.dart';
import 'package:flutter/material.dart';

import '../ContactUs.dart';

Widget DSAiFooter(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Having any issue?", style: TextStyle(fontSize: 18),),
          const SizedBox(height: 15),
          Container(
            width: double.maxFinite,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => {
                   Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const ContactUs(),
                                    ),
                                  ),
              },
              icon: const Icon(Icons.contact_emergency, color: Colors.white),
              label: const Text(
                'Contact Us',
                style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B884),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color:Color(0xFF00B884) )
                  ),
              ),
            ),
          ),
         
          SizedBox(
            height: 10,
          ),
        ],
      ),
    ),
  );
}
