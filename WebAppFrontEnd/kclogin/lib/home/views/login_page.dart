import 'package:flutter/material.dart';
import 'package:kclogin/home/controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginController = LoginController();

  @override
  void initState() {
    super.initState();
    _loginController.initfunction(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keycloak Sign In'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
        children: [
          Text('Ecommerce Web App'),
          SizedBox(height: 50,),
          ElevatedButton(
            onPressed: () async {
              _loginController.checkForKeycloakToken(context);
            },
            child: const Text('Sign In with Google'),
          ),
        ],
      )),
    );
  }
}
