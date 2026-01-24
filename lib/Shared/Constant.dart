import 'package:flutter/material.dart';

class Constant {
  static late double screenWidth;
  static late double screenHeight;

  static void initializeScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height - 30;
  }

  static var scaffoldColor = Color(0xff212121);

  static final String baseAppURL = 'http://192.168.1.5:8081/api/';

  static final String mediaURL = baseAppURL.substring(0, Constant.baseAppURL.length - 5);
}
