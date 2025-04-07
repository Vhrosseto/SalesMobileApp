import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/usuario.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  List<Usuario> _listaUsuarios = [];
  Usuario? _usuarioEmEdicao;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _carregarListaUsuarios();
  }

  Future<void> _carregarListaUsuarios() async {
    _listaUsuarios = await _lerUsuarios();
    setState(() {
      _usuarioEmEdicao = null;
      _nomeController.clear();
      _senhaController.clear();
      _confirmarSenhaController.clear();
    });
  }

  void _cadastrarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String nome = _nomeController.text;
    String senha = _senhaController.text;
    String confirmarSenha = _confirmarSenhaController.text;

    if (_usuarioEmEdicao == null && senha != confirmarSenha) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }

    try {
      List<Usuario> usuariosExistentes = await _lerUsuarios();
      if (_usuarioEmEdicao != null) {
        final index = usuariosExistentes.indexWhere(
          (u) => u.id == _usuarioEmEdicao!.id,
        );
        if (index != -1) {
          usuariosExistentes[index] = Usuario(
            id: _usuarioEmEdicao!.id,
            nome: nome,
            senha: senha.isNotEmpty ? senha : _usuarioEmEdicao!.senha,
          );
          await _escreverUsuarios(usuariosExistentes);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário atualizado com sucesso!')),
          );
        }
      } else {
        int novoId =
            usuariosExistentes.isEmpty ? 1 : usuariosExistentes.last.id + 1;
        final novoUsuario = Usuario(id: novoId, nome: nome, senha: senha);
        usuariosExistentes.add(novoUsuario);
        await _escreverUsuarios(usuariosExistentes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
      }

      _carregarListaUsuarios();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar usuário.')));
    }
  }

  Future<void> _editarUsuario(Usuario usuario) async {
    setState(() {
      _usuarioEmEdicao = usuario;
      _nomeController.text = usuario.nome;
      _senhaController.text = '';
      _confirmarSenhaController.text = '';
    });
  }

  Future<void> _excluirUsuario(Usuario usuario) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Exclusão',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Tem certeza que deseja excluir o usuário "${usuario.nome}"?',
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.grey[800],
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF3BA9F8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false (não excluir)
              },
            ),
            TextButton(
              child: Text(
                'Excluir',
                style: TextStyle(color: Color(0xFF3BA9F8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true (excluir)
              },
            ),
          ],
        );
      },
    ).then((deveExcluir) async {
      if (deveExcluir == true) {
        try {
          List<Usuario> usuariosExistentes = await _lerUsuarios();
          usuariosExistentes.removeWhere((u) => u.id == usuario.id);
          await _escreverUsuarios(usuariosExistentes);
          _carregarListaUsuarios(); // Recarrega a lista após a exclusão
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário excluído com sucesso!')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao excluir usuário.')));
        }
      }
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/usuarios.json');
  }

  Future<List<Usuario>> _lerUsuarios() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _escreverUsuarios(List<Usuario> usuarios) async {
    final file = await _localFile;
    final jsonString = json.encode(usuarios.map((u) => u.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Usuário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome de usuário é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (_usuarioEmEdicao == null &&
                      (value == null || value.isEmpty)) {
                    return 'A senha é obrigatória';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF175B8C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (_usuarioEmEdicao == null &&
                      (value == null || value.isEmpty)) {
                    return 'A confirmação de senha é obrigatória';
                  }
                  if (_senhaController.text != value) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _cadastrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3BA9F8),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  _usuarioEmEdicao == null ? 'Cadastrar' : 'Salvar',
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ),
              if (_usuarioEmEdicao != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _usuarioEmEdicao = null;
                      _nomeController.clear();
                      _senhaController.clear();
                      _confirmarSenhaController.clear();
                    });
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: Text(
                    'Cancelar Edição',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              SizedBox(height: 20.0),
              Text(
                'Usuários Cadastrados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[800]),
                    dataRowColor: WidgetStateProperty.all(Colors.grey[850]),
                    dividerThickness: 1,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF175B8C)),
                      ),
                    ),
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'ID',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nome',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Editar',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                    rows:
                        _listaUsuarios
                            .map(
                              (usuario) => DataRow(
                                key: ValueKey(usuario.id),
                                cells: <DataCell>[
                                  DataCell(
                                    Text(
                                      usuario.id.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      usuario.nome,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => _editarUsuario(usuario),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => _excluirUsuario(usuario),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
