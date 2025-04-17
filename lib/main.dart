  import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Força de Vendas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), 
    );
  }
}
