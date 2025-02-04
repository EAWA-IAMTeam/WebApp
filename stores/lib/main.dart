import 'package:flutter/material.dart';
import 'link_stores.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Stores',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: LinkStorePage(),
    );
  }
}
