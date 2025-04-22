import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../controllers/usuario_controller.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final _usuarioController = UsuarioController();
  List<Usuario> _usuarios = [];
  Usuario? _usuarioEmEdicao;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listaUsuarios = await _usuarioController.listarUsuarios();
      setState(() {
        _usuarios = listaUsuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar usuários: ${e.toString()}')),
      );
    }
  }

  void _limparFormulario() {
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

    setState(() {
      _isLoading = true;
    });

    try {
      String nome = _nomeController.text;
      String senha = _senhaController.text;

      if (_usuarioEmEdicao != null) {
        final usuarioAtualizado = Usuario(
          id: _usuarioEmEdicao!.id,
          nome: nome,
          senha: senha.isNotEmpty ? senha : _usuarioEmEdicao!.senha,
        );

        await _usuarioController.atualizarUsuario(usuarioAtualizado);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário atualizado com sucesso!')),
        );
      } else {
        int novoId = _usuarios.isEmpty ? 1 : _usuarios.last.id + 1;
        final novoUsuario = Usuario(id: novoId, nome: nome, senha: senha);
        await _usuarioController.adicionarUsuario(novoUsuario);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
      }

      await _carregarUsuarios();
      _limparFormulario();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editarUsuario(Usuario usuario) async {
    setState(() {
      _usuarioEmEdicao = usuario;
      _nomeController.text = usuario.nome;
      _senhaController.clear();
      _confirmarSenhaController.clear();
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
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Excluir',
                style: TextStyle(color: Color(0xFF3BA9F8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((deveExcluir) async {
      if (deveExcluir == true) {
        setState(() {
          _isLoading = true;
        });

        try {
          await _usuarioController.excluirUsuario(usuario.id);
          await _carregarUsuarios();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário excluído com sucesso!')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir usuário: ${e.toString()}')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                        if (value.length < 3) {
                          return 'O nome deve ter pelo menos 3 caracteres';
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
                        labelText: _usuarioEmEdicao == null ? 'Senha *' : 'Nova Senha',
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
                        if (_usuarioEmEdicao == null && (value == null || value.isEmpty)) {
                          return 'A senha é obrigatória';
                        }
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
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
                        labelText: _usuarioEmEdicao == null ? 'Confirmar Senha *' : 'Confirmar Nova Senha',
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
                        if (_usuarioEmEdicao == null && (value == null || value.isEmpty)) {
                          return 'A confirmação de senha é obrigatória';
                        }
                        if (_senhaController.text.isNotEmpty && value != _senhaController.text) {
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
                        onPressed: _limparFormulario,
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
                          rows: _usuarios
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
