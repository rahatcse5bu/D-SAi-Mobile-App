import 'package:flutter/material.dart';

PreferredSizeWidget? DSAiAppBar( {String title='D-SAi QR Code System'}){
  return AppBar(
    backgroundColor: Color(0xFF00B884),
        title: Text(title.toString(),style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        centerTitle: true,
          iconTheme: IconThemeData(
    color: Colors.white, // Set drawer icon color to yellow
    size: 30,            // Optionally, set a custom size
  ),
      );
}