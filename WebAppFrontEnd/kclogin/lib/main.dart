import 'package:flutter/material.dart';
import 'package:kclogin/home/views/login_page.dart';



void main() async{
   //await dotenv.load();
   runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Login with Keycloak',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Start with the LoginPage
    );
  }
}
