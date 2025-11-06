import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: accentAmber,
      width: 2.0,
    ),
  ),
);

const titleStyle = TextStyle(
  color: Colors.black,
  fontSize: 28,
  fontWeight: FontWeight.bold,
  );

const mainHeadingStyle = TextStyle(
  color: greenPrimary,
  fontSize: 28,
  fontWeight: FontWeight.bold,
  );