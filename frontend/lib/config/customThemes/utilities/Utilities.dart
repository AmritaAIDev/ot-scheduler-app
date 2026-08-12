import 'package:flutter/material.dart';

class Utilities {

  static InputDecoration otSearchBoxDecoration = InputDecoration(
    hintText: 'Filter by OT number',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey),
    ),
    filled: true,
    fillColor: Colors.grey[200],
  );



}