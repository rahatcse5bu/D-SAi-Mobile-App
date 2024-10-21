import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const kAppBarColor = Color(0xFF00B884);
const kPrimaryTextColor = Colors.black87;
const kSecondaryTextColor = Colors.grey;
const kTextColorWhite = Colors.white;

class CompanyCard extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final VoidCallback onShowQRDialog;
  const CompanyCard(
      {Key? key, required this.companyData, required this.onShowQRDialog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.email, color: kAppBarColor, size: 24),
                const SizedBox(width: 10),
                Text(companyData['companyMailId'] ?? 'N/A',
                    style: TextStyle(fontSize: 14.sp))
              ],
            ),
             SizedBox(width: 10.w,),
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.phone, color: kAppBarColor, size: 24),
                SizedBox(
                  width: 10,
                ),
                Text(companyData['companyPhone'] ?? 'N/A',
                    style: TextStyle(fontSize: 14))
              ],
            ),
          ]),
          SizedBox(height:10.h),
          Row(
             mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_city,
                      color: kAppBarColor, size: 24),
                  const SizedBox(width: 10),
                  Text(companyData['companyAddress'] ?? 'N/A',
                      style: TextStyle(fontSize: 14.sp))
                ],
              ),
              SizedBox(width: 10.w,),
              GestureDetector(
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    
                      backgroundColor:
                          WidgetStatePropertyAll(Color(0xFF10A7AE))),
                  onPressed: onShowQRDialog,
                  label: Text(
                    'Generate QR Code',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  icon:
                      Icon(Icons.qr_code, size: 14.sp, color: Colors.white),
                  iconAlignment: IconAlignment.end,
                ),
              ),
            ],
          ),
        ],
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
  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kAppBarColor, size: 20),
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
}
