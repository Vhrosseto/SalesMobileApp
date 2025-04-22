import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/cliente.dart';

class ClienteController {
  List<Cliente> _clientes = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/clientes.json');
  }

  Future<void> _carregarClientes() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _clientes = jsonList.map((json) => Cliente.fromJson(json)).toList();
      }
    } catch (e) {
      _clientes = [];
    }
  }

  Future<void> _salvarClientes() async {
    final file = await _localFile;
    final jsonString = json.encode(_clientes.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  bool _validarCpfCnpj(String cpfCnpj) {
    final numeros = cpfCnpj.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numeros.length == 11) {
      return true;
    }
    
    if (numeros.length == 14) {
      return true;
    }
    
    return false;
  }

  bool _validarEmail(String? email) {
    if (email == null || email.isEmpty) return true;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<Cliente> adicionarCliente(Cliente cliente) async {
    await _carregarClientes();

    if (!_validarCpfCnpj(cliente.cpfCnpj)) {
      throw Exception('CPF/CNPJ inválido');
    }

    if (!_validarEmail(cliente.email)) {
      throw Exception('Email inválido');
    }

    if (_clientes.any((c) => c.cpfCnpj == cliente.cpfCnpj)) {
      throw Exception('Já existe um cliente com este CPF/CNPJ');
    }

    _clientes.add(cliente);
    await _salvarClientes();
    return cliente;
  }

  Future<Cliente?> buscarClientePorId(int id) async {
    await _carregarClientes();
    try {
      return _clientes.firstWhere((cliente) => cliente.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Cliente>> listarClientes() async {
    await _carregarClientes();
    return _clientes;
  }

  Future<Cliente> atualizarCliente(Cliente clienteAtualizado) async {
    await _carregarClientes();

    if (!_validarCpfCnpj(clienteAtualizado.cpfCnpj)) {
      throw Exception('CPF/CNPJ inválido');
    }

    if (!_validarEmail(clienteAtualizado.email)) {
      throw Exception('Email inválido');
    }

    final index = _clientes.indexWhere((c) => c.id == clienteAtualizado.id);
    if (index == -1) {
      throw Exception('Cliente não encontrado');
    }

    _clientes[index] = clienteAtualizado;
    await _salvarClientes();
    return clienteAtualizado;
  }

  Future<void> excluirCliente(int id) async {
    await _carregarClientes();
    
    final index = _clientes.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Cliente não encontrado');
    }
    _clientes.removeAt(index);
    await _salvarClientes();
  }

  Future<List<Cliente>> buscarClientesPorNome(String nome) async {
    await _carregarClientes();
    return _clientes
        .where((cliente) =>
            cliente.nome.toLowerCase().contains(nome.toLowerCase()))
        .toList();
  }
} 