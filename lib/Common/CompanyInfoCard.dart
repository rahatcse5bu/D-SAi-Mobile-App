import 'package:flutter/material.dart';

const kAppBarColor = Color(0xFF00B884);
const kPrimaryTextColor = Colors.black87;
const kSecondaryTextColor = Colors.grey;
const kTextColorWhite = Colors.white;

class CompanyCard extends StatelessWidget {
  final Map<String, dynamic> companyData;

  const CompanyCard({Key? key, required this.companyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2, // Adds shadow for a 3D effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            Row(
              children: [
                const Icon(Icons.business, color: kAppBarColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  companyData['companyName'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Company Address
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Address:',
              value: companyData['companyAddress'] ?? 'N/A',
            ),

            const SizedBox(height: 10),

            // Company Email
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email:',
              value: companyData['companyMailId'] ?? 'N/A',
            ),

            const SizedBox(height: 10),

            // Company Number
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Phone:',
              value: companyData['companyNumber']?.toString() ?? 'N/A',
            ),

            const SizedBox(height: 16),

            
          ],
        ),
      ),
    );
  }

  // Function to handle contact button press
  void _contactCompany(BuildContext context) {
    String companyMail = companyData['companyMailId'] ?? '';
    String companyNumber = companyData['companyNumber']?.toString() ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Contacting Company via Email: $companyMail or Phone: $companyNumber",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Helper function to create info rows in the card
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kAppBarColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label ',
              style: const TextStyle(fontSize: 16, color: kPrimaryTextColor, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontSize: 16, color: kSecondaryTextColor, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
