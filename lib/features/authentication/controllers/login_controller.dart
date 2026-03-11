import 'package:flutter/material.dart';

class LoginController {
  final email = TextEditingController();
  final password = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  void dispose() {
    email.dispose();
    password.dispose();
  }
}
