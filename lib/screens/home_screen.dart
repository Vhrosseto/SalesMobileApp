import 'package:flutter/material.dart';
import 'usuarios_screen.dart';
import 'clientes_screen.dart';
import 'produtos_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    UsuariosScreen(),
    ClientesScreen(),
    ProdutosScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Usuários',
            backgroundColor: Color.fromARGB(255, 65, 64, 64),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Clientes',
            backgroundColor: Color.fromARGB(255, 65, 64, 64),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Produtos',
            backgroundColor: Color.fromARGB(255, 65, 64, 64),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF3BA9F8),
        unselectedItemColor: Colors.white,

        onTap: (int index) {
          if (index == 3) {
            _logout();
          } else {
            _onItemTapped(index);
          }
        },
      ),
      backgroundColor: Colors.grey[900], // Garante o fundo cinza no Scaffold
    );
  }
}
