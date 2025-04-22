import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/produto.dart';
import '../controllers/produto_controller.dart';

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
  final _produtoController = ProdutoController();
  List<Produto> _produtos = [];
  Produto? _produtoEmEdicao;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listaProdutos = await _produtoController.listarProdutos();
      setState(() {
        _produtos = listaProdutos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos: ${e.toString()}')),
      );
    }
  }

  void _limparFormulario() {
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
      setState(() {
        _isLoading = true;
      });

      try {
        int novoId = _produtos.isEmpty ? 1 : _produtos.last.id + 1;
        String nome = _nomeController.text;
        String unidade = _unidadeSelecionada!;
        double quantidadeEstoque = double.parse(_quantidadeEstoqueController.text);
        double precoVenda = double.parse(_precoVendaController.text);
        int status = _statusSelecionado!;
        double? custo = _custoController.text.isNotEmpty
            ? double.parse(_custoController.text)
            : null;
        String? codigoBarra = _codigoBarraController.text.isNotEmpty
            ? _codigoBarraController.text
            : null;

        final novoProduto = Produto(
          id: _produtoEmEdicao?.id ?? novoId,
          nome: nome,
          unidade: unidade,
          quantidadeEstoque: quantidadeEstoque,
          precoVenda: precoVenda,
          status: status,
          custo: custo,
          codigoBarra: codigoBarra,
        );

        if (_produtoEmEdicao != null) {
          await _produtoController.atualizarProduto(novoProduto);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto atualizado com sucesso!')),
          );
        } else {
          await _produtoController.adicionarProduto(novoProduto);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto cadastrado com sucesso!')),
          );
        }

        await _carregarProdutos();
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
        setState(() {
          _isLoading = true;
        });

        try {
          await _produtoController.excluirProduto(produto.id);
          await _carregarProdutos();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto excluído com sucesso!')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir produto: ${e.toString()}')),
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
          'Cadastro de Produtos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
      ),
      backgroundColor: Colors.grey[900],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                            Center(
                              child: TextButton(
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
                                  _produtos
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
