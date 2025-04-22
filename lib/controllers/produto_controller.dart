import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/produto.dart';

class ProdutoController {
  List<Produto> _produtos = [];

  bool _validarPrecos(double precoVenda, double? custo) {
    if (precoVenda <= 0) return false;
    if (custo != null && custo <= 0) return false;
    if (custo != null && precoVenda < custo) return false;
    return true;
  }

  bool _validarQuantidadeEstoque(double quantidade) {
    return quantidade >= 0;
  }

  bool _validarCodigoBarra(String? codigoBarra) {
    if (codigoBarra == null || codigoBarra.isEmpty) return true;
    return true;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/produtos.json');
  }

  Future<void> _carregarProdutos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _produtos = jsonList.map((json) => Produto.fromJson(json)).toList();
      }
    } catch (e) {
      _produtos = [];
    }
  }

  Future<void> _salvarProdutos() async {
    final file = await _localFile;
    final jsonString = json.encode(_produtos.map((p) => p.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<Produto> adicionarProduto(Produto produto) async {
    await _carregarProdutos();

    if (!_validarPrecos(produto.precoVenda, produto.custo)) {
      throw Exception('Preços inválidos');
    }

    if (!_validarQuantidadeEstoque(produto.quantidadeEstoque)) {
      throw Exception('Quantidade em estoque inválida');
    }

    if (!_validarCodigoBarra(produto.codigoBarra)) {
      throw Exception('Código de barras inválido');
    }

    if (produto.codigoBarra != null && 
        _produtos.any((p) => p.codigoBarra == produto.codigoBarra)) {
      throw Exception('Já existe um produto com este código de barras');
    }

    _produtos.add(produto);
    await _salvarProdutos();
    return produto;
  }

  Future<Produto?> buscarProdutoPorId(int id) async {
    await _carregarProdutos();
    try {
      return _produtos.firstWhere((produto) => produto.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Produto>> listarProdutos() async {
    await _carregarProdutos();
    return _produtos;
  }

  Future<Produto> atualizarProduto(Produto produtoAtualizado) async {
    await _carregarProdutos();

    if (!_validarPrecos(produtoAtualizado.precoVenda, produtoAtualizado.custo)) {
      throw Exception('Preços inválidos');
    }

    if (!_validarQuantidadeEstoque(produtoAtualizado.quantidadeEstoque)) {
      throw Exception('Quantidade em estoque inválida');
    }

    if (!_validarCodigoBarra(produtoAtualizado.codigoBarra)) {
      throw Exception('Código de barras inválido');
    }

    final index = _produtos.indexWhere((p) => p.id == produtoAtualizado.id);
    if (index == -1) {
      throw Exception('Produto não encontrado');
    }

    _produtos[index] = produtoAtualizado;
    await _salvarProdutos();
    return produtoAtualizado;
  }

  Future<void> excluirProduto(int id) async {
    await _carregarProdutos();
    
    final index = _produtos.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Produto não encontrado');
    }
    _produtos.removeAt(index);
    await _salvarProdutos();
  }

  Future<List<Produto>> buscarProdutosPorNome(String nome) async {
    await _carregarProdutos();
    return _produtos
        .where((produto) =>
            produto.nome.toLowerCase().contains(nome.toLowerCase()))
        .toList();
  }

  Future<Produto?> buscarProdutoPorCodigoBarra(String codigoBarra) async {
    await _carregarProdutos();
    try {
      return _produtos.firstWhere((p) => p.codigoBarra == codigoBarra);
    } catch (e) {
      return null;
    }
  }

  Future<bool> verificarDisponibilidadeEstoque(int id, double quantidade) async {
    final produto = await buscarProdutoPorId(id);
    if (produto == null) return false;
    return produto.quantidadeEstoque >= quantidade;
  }

  Future<void> atualizarEstoque(int id, double quantidade) async {
    await _carregarProdutos();
    
    final index = _produtos.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Produto não encontrado');
    }

    final novoEstoque = _produtos[index].quantidadeEstoque + quantidade;
    if (novoEstoque < 0) {
      throw Exception('Quantidade em estoque não pode ser negativa');
    }

    _produtos[index] = Produto(
      id: _produtos[index].id,
      nome: _produtos[index].nome,
      unidade: _produtos[index].unidade,
      quantidadeEstoque: novoEstoque,
      precoVenda: _produtos[index].precoVenda,
      status: _produtos[index].status,
      custo: _produtos[index].custo,
      codigoBarra: _produtos[index].codigoBarra,
    );
    
    await _salvarProdutos();
  }
} 