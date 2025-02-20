import 'package:flutter/material.dart';
import 'package:kclogin/home/views/create_user.dart';
import 'package:kclogin/home/controllers/auth_controller.dart';
import 'package:kclogin/home/controllers/home_controller.dart';
import 'package:kclogin/home/views/login_page.dart';
import 'package:kclogin/order/order_view.dart';
import 'package:kclogin/product/link_product.dart';
import 'package:kclogin/store/link_stores.dart';
import 'package:kclogin/home/views/update_user.dart';

class HomePage extends StatefulWidget {
  final String googleAccessToken;
  final String keycloakAccessToken;
  final String keycloakRefreshToken;
  final String email;

  const HomePage({
    Key? key,
    required this.googleAccessToken,
    required this.keycloakAccessToken,
    required this.keycloakRefreshToken,
    required this.email,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
final authController = AuthController();
final HomeController _homeController = HomeController(); 

  @override
  void initState() {
    super.initState();
    authController.fetchKeycloakConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.keycloakAccessToken.isNotEmpty
                  ? Column(
                      children: [
                        //Text('Email: ${widget.email}'),
                        //SizedBox(height: 10),
                        //Text(
                        //    'Keycloak Access Token: ${widget.keycloakAccessToken}'),
                        //SizedBox(height: 10),
                        // Text(
                        //     'Keycloak Refresh Token: ${widget.keycloakRefreshToken}'),
                        // const SizedBox(height: 20),

                        // First Row with Select Company, Create Company, and Join Company
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateUserPage()),
                                );
                              },
                              child: const Text('Update User'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateUserPage()),
                                );
                              },
                              child: const Text('Create User'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LinkStorePage(keycloakAccessToken: widget.keycloakAccessToken, keycloakRefreshToken: widget.keycloakRefreshToken,)),
                                );
                              },
                              child: const Text('Link Store'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // html.window.location.href = 'http://localhost:3003';
                                // _launchURL();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LinkProductPage(keycloakAccessToken: widget.keycloakAccessToken, keycloakRefreshToken: widget.keycloakRefreshToken,)),
                                );
                              },
                              child: const Text('Link Inventory'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrdersView(keycloakAccessToken: widget.keycloakAccessToken, keycloakRefreshToken: widget.keycloakRefreshToken,)),
                                );
                              },
                              child: const Text('View Order'),
                            ),
                            const SizedBox(width: 10),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     _callApiWithToken();
                            //   },
                            //   child: const Text('Connect with APISIX'),
                            // ),
                          ],
                        ),
                        // Second Row Logout
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _homeController.logout(context, widget.keycloakRefreshToken),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text('Login failed. Please try again.'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
