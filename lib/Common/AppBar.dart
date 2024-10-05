import 'package:flutter/material.dart';

PreferredSizeWidget? DSAiAppBar( {String title=''}){
  return AppBar(
    backgroundColor: Color(0xFF00B884),
        title: Text(title.toString(),style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: null,
          iconTheme: const IconThemeData(
    color: Colors.white, // Set drawer icon color to yellow
    size: 30,            // Optionally, set a custom size
  ),
      );
}