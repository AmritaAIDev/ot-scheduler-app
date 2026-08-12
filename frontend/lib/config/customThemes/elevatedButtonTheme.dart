import 'package:flutter/material.dart';

class MyElevatedButtonTheme {
  static final elevatedButtonTheme1 = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      //backgroundColor: Colors.cyan[600],
      backgroundColor: Colors.lightBlueAccent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
      textStyle: TextStyle(fontSize: 16),
    )
  );

  static final elevatedButtonTheme3 = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        //backgroundColor: Colors.cyan[600],
        backgroundColor: Colors.lightBlueAccent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        textStyle: TextStyle(fontSize: 16),
      )
  );

  static final elevatedButtonTheme2 = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[300],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        textStyle: TextStyle(fontSize: 14),
      )
  );
}