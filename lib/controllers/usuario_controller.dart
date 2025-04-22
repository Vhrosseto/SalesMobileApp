import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/usuario.dart';

class UsuarioController {
  List<Usuario> _usuarios = [];

  bool _validarNome(String nome) {
    if (nome.isEmpty) return false;
    if (nome.length < 3) return false;
    return true;
  }

  bool _validarSenha(String senha) {
    if (senha.isEmpty) return false;
    if (senha.length < 6) return false;
    return true;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/usuarios.json');
  }

  Future<void> _carregarUsuarios() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _usuarios = jsonList.map((json) => Usuario.fromJson(json)).toList();
      }
    } catch (e) {
      _usuarios = [];
    }
  }

  Future<void> _salvarUsuarios() async {
    final file = await _localFile;
    final jsonString = json.encode(_usuarios.map((u) => u.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<Usuario> adicionarUsuario(Usuario usuario) async {
    await _carregarUsuarios();

    if (!_validarNome(usuario.nome)) {
      throw Exception('Nome de usuário inválido');
    }

    if (!_validarSenha(usuario.senha)) {
      throw Exception('Senha inválida');
    }

    if (_usuarios.any((u) => u.nome == usuario.nome)) {
      throw Exception('Já existe um usuário com este nome');
    }

    _usuarios.add(usuario);
    await _salvarUsuarios();
    return usuario;
  }

  Future<Usuario?> buscarUsuarioPorId(int id) async {
    await _carregarUsuarios();
    try {
      return _usuarios.firstWhere((usuario) => usuario.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Usuario>> listarUsuarios() async {
    await _carregarUsuarios();
    return _usuarios;
  }

  Future<Usuario> atualizarUsuario(Usuario usuarioAtualizado) async {
    await _carregarUsuarios();

    if (!_validarNome(usuarioAtualizado.nome)) {
      throw Exception('Nome de usuário inválido');
    }

    if (usuarioAtualizado.senha.isNotEmpty && !_validarSenha(usuarioAtualizado.senha)) {
      throw Exception('Senha inválida');
    }

    final index = _usuarios.indexWhere((u) => u.id == usuarioAtualizado.id);
    if (index == -1) {
      throw Exception('Usuário não encontrado');
    }

    if (_usuarios.any((u) => u.nome == usuarioAtualizado.nome && u.id != usuarioAtualizado.id)) {
      throw Exception('Já existe um usuário com este nome');
    }

    _usuarios[index] = usuarioAtualizado;
    await _salvarUsuarios();
    return usuarioAtualizado;
  }

  Future<void> excluirUsuario(int id) async {
    await _carregarUsuarios();
    
    final index = _usuarios.indexWhere((u) => u.id == id);
    if (index == -1) {
      throw Exception('Usuário não encontrado');
    }
    _usuarios.removeAt(index);
    await _salvarUsuarios();
  }

  Future<Usuario?> autenticarUsuario(String nome, String senha) async {
    await _carregarUsuarios();
    try {
      return _usuarios.firstWhere(
        (usuario) => usuario.nome == nome && usuario.senha == senha,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Usuario>> buscarUsuariosPorNome(String nome) async {
    await _carregarUsuarios();
    return _usuarios
        .where((usuario) =>
            usuario.nome.toLowerCase().contains(nome.toLowerCase()))
        .toList();
  }

  Future<void> alterarSenha(int id, String senhaAtual, String novaSenha) async {
    await _carregarUsuarios();
    
    final index = _usuarios.indexWhere((u) => u.id == id);
    if (index == -1) {
      throw Exception('Usuário não encontrado');
    }

    if (_usuarios[index].senha != senhaAtual) {
      throw Exception('Senha atual incorreta');
    }

    if (!_validarSenha(novaSenha)) {
      throw Exception('Nova senha inválida');
    }

    _usuarios[index] = Usuario(
      id: _usuarios[index].id,
      nome: _usuarios[index].nome,
      senha: novaSenha,
    );
    
    await _salvarUsuarios();
  }
} 