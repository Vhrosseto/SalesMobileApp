import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importa a tela de login

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
      home: LoginScreen(), // Define a LoginScreen como a tela inicial
    );
  }
}
