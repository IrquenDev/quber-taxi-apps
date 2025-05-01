import 'package:flutter/material.dart';
import 'package:quber_taxi/common/pages/login.dart';
import 'package:quber_taxi/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const LoginPage()
    );
  }
}