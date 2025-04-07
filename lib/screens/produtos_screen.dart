import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/produto.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  _ProdutosScreenState createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String? _unidadeSelecionada;
  final _quantidadeEstoqueController = TextEditingController();
  final _precoVendaController = TextEditingController();
  int? _statusSelecionado;
  final _custoController = TextEditingController();
  final _codigoBarraController = TextEditingController();
  List<Produto> _listaProdutos = [];
  Produto? _produtoEmEdicao;

  @override
  void initState() {
    super.initState();
    _carregarListaProdutos();
  }

  Future<void> _carregarListaProdutos() async {
    _listaProdutos = await _lerProdutos();
    setState(() {
      _produtoEmEdicao = null;
      _nomeController.clear();
      _unidadeSelecionada = null;
      _quantidadeEstoqueController.clear();
      _precoVendaController.clear();
      _statusSelecionado = null;
      _custoController.clear();
      _codigoBarraController.clear();
    });
  }

  void _cadastrarProduto() async {
    if (_formKey.currentState!.validate()) {
      int novoId = _listaProdutos.isEmpty ? 1 : _listaProdutos.last.id + 1;
      String nome = _nomeController.text;
      String unidade = _unidadeSelecionada!;
      double quantidadeEstoque = double.parse(
        _quantidadeEstoqueController.text,
      );
      double precoVenda = double.parse(_precoVendaController.text);
      int status = _statusSelecionado!;
      double? custo =
          _custoController.text.isNotEmpty
              ? double.parse(_custoController.text)
              : null;
      String? codigoBarra =
          _codigoBarraController.text.isNotEmpty
              ? _codigoBarraController.text
              : null;

      final novoProduto = Produto(
        id: novoId,
        nome: nome,
        unidade: unidade,
        quantidadeEstoque: quantidadeEstoque,
        precoVenda: precoVenda,
        status: status,
        custo: custo,
        codigoBarra: codigoBarra,
      );

      try {
        List<Produto> produtosExistentes = await _lerProdutos();
        if (_produtoEmEdicao != null) {
          final index = produtosExistentes.indexWhere(
            (p) => p.id == _produtoEmEdicao!.id,
          );
          if (index != -1) {
            produtosExistentes[index] = novoProduto;
            await _escreverProdutos(produtosExistentes);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produto atualizado com sucesso!')),
            );
          }
        } else {
          produtosExistentes.add(novoProduto);
          await _escreverProdutos(produtosExistentes);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto cadastrado com sucesso!')),
          );
        }
        _carregarListaProdutos();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar produto.')));
      }
    }
  }

  Future<void> _editarProduto(Produto produto) async {
    setState(() {
      _produtoEmEdicao = produto;
      _nomeController.text = produto.nome;
      _unidadeSelecionada = produto.unidade;
      _quantidadeEstoqueController.text = produto.quantidadeEstoque.toString();
      _precoVendaController.text = produto.precoVenda.toString();
      _statusSelecionado = produto.status;
      _custoController.text = produto.custo?.toString() ?? '';
      _codigoBarraController.text = produto.codigoBarra ?? '';
    });
  }

  Future<void> _excluirProduto(Produto produto) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Exclusão',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Tem certeza que deseja excluir o produto "${produto.nome}"?',
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
        try {
          List<Produto> produtosExistentes = await _lerProdutos();
          produtosExistentes.removeWhere((p) => p.id == produto.id);
          await _escreverProdutos(produtosExistentes);
          _carregarListaProdutos();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto excluído com sucesso!')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao excluir produto.')));
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
    return File('$path/produtos.json');
  }

  Future<List<Produto>> _lerProdutos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Produto.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _escreverProdutos(List<Produto> produtos) async {
    final file = await _localFile;
    final jsonString = json.encode(produtos.map((p) => p.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Produtos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome *',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'O Nome é obrigatório'
                                  : null,
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Unidade *',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      value: _unidadeSelecionada,
                      items:
                          <String>[
                            'un',
                            'cx',
                            'kg',
                            'lt',
                            'ml',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'A Unidade é obrigatória'
                                  : null,
                      onChanged:
                          (String? newValue) =>
                              setState(() => _unidadeSelecionada = newValue),
                      dropdownColor: Colors.grey[800],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _quantidadeEstoqueController,
                      decoration: InputDecoration(
                        labelText: 'Quantidade em Estoque *',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'A Quantidade é obrigatória'
                                  : null,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _precoVendaController,
                      decoration: InputDecoration(
                        labelText: 'Preço de Venda *',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'O Preço de Venda é obrigatório'
                                  : null,
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Status *',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      value: _statusSelecionado,
                      items:
                          <int>[0, 1].map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                value == 0 ? 'Ativo' : 'Inativo',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                      validator:
                          (value) =>
                              value == null ? 'O Status é obrigatório' : null,
                      onChanged:
                          (int? newValue) =>
                              setState(() => _statusSelecionado = newValue),
                      dropdownColor: Colors.grey[800],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _custoController,
                      decoration: InputDecoration(
                        labelText: 'Custo',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _codigoBarraController,
                      decoration: InputDecoration(
                        labelText: 'Código de Barras',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF175B8C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BA9F8)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarProduto,
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
                          _produtoEmEdicao == null
                              ? 'Cadastrar Produto'
                              : 'Salvar Produto',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                      ),
                    ),
                    if (_produtoEmEdicao != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _produtoEmEdicao = null;
                            _nomeController.clear();
                            _unidadeSelecionada = null;
                            _quantidadeEstoqueController.clear();
                            _precoVendaController.clear();
                            _statusSelecionado = null;
                            _custoController.clear();
                            _codigoBarraController.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: Text(
                          'Cancelar Edição',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    SizedBox(height: 20.0),
                    Text(
                      'Produtos Cadastrados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey[800],
                        ),
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
                              'Unidade',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Estoque',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Preço',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
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
                            _listaProdutos
                                .map(
                                  (produto) => DataRow(
                                    key: ValueKey(produto.id),
                                    cells: <DataCell>[
                                      DataCell(
                                        Text(
                                          produto.id.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          produto.nome,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          produto.unidade.toUpperCase(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          produto.quantidadeEstoque.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          produto.status == 0
                                              ? 'Ativo'
                                              : 'Inativo',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.white70,
                                          ),
                                          onPressed:
                                              () => _editarProduto(produto),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.white70,
                                          ),
                                          onPressed:
                                              () => _excluirProduto(produto),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
