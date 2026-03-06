import 'package:flutter/material.dart';

class Texts12w4 extends StatelessWidget {
  // string
  final String text;
  // color ?
  final Color? color;
  const Texts12w4({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: "Lato"
      ),
    );
  }
} 
      
 