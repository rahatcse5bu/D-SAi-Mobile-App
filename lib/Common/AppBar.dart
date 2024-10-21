import 'package:flutter/material.dart';

PreferredSizeWidget? DSAiAppBar( {String title=''}){
  return AppBar(
    // backgroundColor: Color(0xFF00B884),
    backgroundColor: Colors.transparent,
    
        title: Text(title.toString(),style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        centerTitle: true,
        leadingWidth: 80,
        leading: Container(
          decoration: BoxDecoration(borderRadius:BorderRadius.circular(10) ,border: Border.all(color: Color(0xFF00B884))),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          margin: EdgeInsets.symmetric( horizontal: 5),
          child: Icon(Icons.arrow_back_rounded)),
          iconTheme: const IconThemeData(
    color: Color(0xFF00B884), // Set drawer icon color to yellow
    size: 30,            // Optionally, set a custom size
  ),
      );
}