import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/usuario.dart';
import 'usuarios_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  late Future<List<Usuario>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = _carregarUsuarios();
  }

  Future<List<Usuario>> _carregarUsuarios() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/usuarios.json');
      if (!await file.exists()) {
        return []; 
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      List<Usuario> usuarios =
          jsonList.map((json) => Usuario.fromJson(json)).toList();
      return usuarios;
    } catch (e) {
      return [];
    }
  }

  void _login(List<Usuario> usuariosCarregados) {
    String nomeDigitado = _nomeController.text;
    String senhaDigitada = _senhaController.text;


    if (usuariosCarregados.isEmpty &&
        nomeDigitado == 'admin' &&
        senhaDigitada == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsuariosScreen()),
      );
      return;
    }

    Usuario? usuarioAutenticado;
    for (var user in usuariosCarregados) {
      if (user.nome == nomeDigitado && user.senha == senhaDigitada) {
        usuarioAutenticado = user;
        break;
      }
    }

    if (usuarioAutenticado != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro de Login', style: TextStyle(color: Colors.white)),
            content: Text(
              'Nome de usuário ou senha incorretos.',
              style: TextStyle(color: Colors.white70),
            ),
            backgroundColor: Colors.grey[800],
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Color(0xFF3BA9F8))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], 
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                margin: EdgeInsets.only(bottom: 30.0),
                decoration: BoxDecoration(
                  color: Color(0xFF175B8C),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Center(
                  child: Text(
                    'SalesMobile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nomeController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _senhaController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              FutureBuilder<List<Usuario>>(
                future: _usuariosFuture,
                builder: (context, snapshot) {
                  List<Usuario> usuariosCarregados = snapshot.data ?? [];
                  return ElevatedButton(
                    onPressed: () => _login(usuariosCarregados),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3BA9F8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Entrar',
                      style: TextStyle(color: Colors.grey[900]),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
