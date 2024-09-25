import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF00B884);
const kPrimaryTextColor = Colors.black87;
const kSecondaryTextColor = Colors.grey;

class EmployeeCard extends StatelessWidget {
  final String employeeName;
  final String position;
  final String employeeId;

  const EmployeeCard({
    Key? key,
    required this.employeeName,
    required this.position,
    required this.employeeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // CircleAvatar(child: Text(employeeName[0]),
                // backgroundImage: AssetImage('assets/profile.png'),
                // ),
                Image.asset("assets/profile.png"),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "$employeeName .",
                          style: TextStyle(
                              fontSize: 18,
                              color: kPrimaryTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.star, color: Colors.yellow,),
                        Text(
                          "4.5",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Image.asset("assets/position.png"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          position,
                          style: TextStyle(
                              fontSize: 14, color: kSecondaryTextColor),
                        ),
                        SizedBox(width: 6,),
                        Container(
                          decoration: BoxDecoration(color: const Color.fromARGB(255, 220, 226, 223),borderRadius: BorderRadius.circular(20) ),
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: Colors.green, radius: 6,), 
                              SizedBox(width: 5),
                              Text("Active", style: TextStyle(fontSize: 14),),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                )
              ],
            )
            // Employee Name with Icon
            // Row(
            //   children: [
            //     const Icon(Icons.person, color: kPrimaryColor, size: 24),
            //     const SizedBox(width: 10),
            //     Text(
            //       employeeName,
            //       style: const TextStyle(
            //         fontSize: 22,
            //         fontWeight: FontWeight.bold,
            //         color: kPrimaryTextColor,
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 10),

            // // Employee Position
            // _buildInfoRow(
            //   icon: Icons.work_outline,
            //   label: 'Position:',
            //   value: position,
            // ),

            // const SizedBox(height: 10),

            // // Employee ID
            // _buildInfoRow(
            //   icon: Icons.badge_outlined,
            //   label: 'Employee ID:',
            //   value: employeeId,
            // ),

            // const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Helper function to create info rows in the card
  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label ',
              style: const TextStyle(
                  fontSize: 16,
                  color: kPrimaryTextColor,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                      fontSize: 16,
                      color: kSecondaryTextColor,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Function to handle contact button press
  void _contactEmployee(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Contacting Employee $employeeName with ID: $employeeId",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
