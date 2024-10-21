import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../HomePage.dart';

Widget DSAiAppBar2({String title = '', required BuildContext context}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
    child: AppBar(
      // backgroundColor: Color(0xFF00B884),
      backgroundColor: Colors.transparent,
      title: Text(
        title.toString(),
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leadingWidth: 55.w,

      leading: GestureDetector(
        onTap:  () => {
                // Pop all routes and navigate to HomePage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false, // Remove all routes
                )
              },
        child: IconButton(
            onPressed: () => {
                  // Pop all routes and navigate to HomePage
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false, // Remove all routes
                  )
                },
            icon: Icon(Icons.arrow_circle_left_rounded)),
      ),

      //  GestureDetector(
      //   onTap: () => {
      //     // Pop all routes and navigate to HomePage
      //     Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (context) => HomePage()),
      //       (Route<dynamic> route) => false, // Remove all routes
      //     )
      //   },
      //   child: Container(
      //     // height: 10,
      //       // decoration: BoxDecoration(
      //       //   // color: Colors.red,
      //       //     borderRadius: BorderRadius.circular(10),
      //       //     border: Border.all(color: Color(0xFF00B884))),
      //       padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
      //       margin: EdgeInsets.symmetric(horizontal: 3.w),
      //       child: Icon(Icons.arrow_back_rounded, size: 25.sp,)),
      // ),
      iconTheme: IconThemeData(
        color: Color(0xFF00B884), // Set drawer icon color to yellow
        size: 40.sp, // Optionally, set a custom size
      ),
    ),
  );
}
