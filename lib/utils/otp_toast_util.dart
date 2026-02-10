import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OtpToastUtil {
  static void showOtpToast(String otp) {
    Fluttertoast.showToast(
      msg: "Your OTP is: $otp",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
