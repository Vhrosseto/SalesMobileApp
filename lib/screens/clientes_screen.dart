import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cliente.dart'; // Importe o model Cliente

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String? _tipoSelecionado;
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  List<Cliente> _listaClientes = [];
  Cliente? _clienteEmEdicao;

  @override
  void initState() {
    super.initState();
    _carregarListaClientes();
  }

  Future<void> _carregarListaClientes() async {
    _listaClientes = await _lerClientes();
    setState(() {
      _clienteEmEdicao = null;
      _nomeController.clear();
      _tipoSelecionado = null;
      _cpfCnpjController.clear();
      _emailController.clear();
      _telefoneController.clear();
      _cepController.clear();
      _enderecoController.clear();
      _bairroController.clear();
      _cidadeController.clear();
      _ufController.clear();
    });
  }

  void _cadastrarCliente() async {
    if (_formKey.currentState!.validate()) {
      int novoId = _listaClientes.isEmpty ? 1 : _listaClientes.last.id + 1;
      String nome = _nomeController.text;
      String? tipo = _tipoSelecionado;
      String cpfCnpj = _cpfCnpjController.text;
      String? email =
          _emailController.text.isNotEmpty ? _emailController.text : null;
      String? telefone =
          _telefoneController.text.isNotEmpty ? _telefoneController.text : null;
      String? cep = _cepController.text.isNotEmpty ? _cepController.text : null;
      String? endereco =
          _enderecoController.text.isNotEmpty ? _enderecoController.text : null;
      String? bairro =
          _bairroController.text.isNotEmpty ? _bairroController.text : null;
      String? cidade =
          _cidadeController.text.isNotEmpty ? _cidadeController.text : null;
      String? uf = _ufController.text.isNotEmpty ? _ufController.text : null;

      final novoCliente = Cliente(
        id: novoId,
        nome: nome,
        tipo: tipo!,
        cpfCnpj: cpfCnpj,
        email: email,
        telefone: telefone,
        cep: cep,
        endereco: endereco,
        bairro: bairro,
        cidade: cidade,
        uf: uf,
      );

      try {
        List<Cliente> clientesExistentes = await _lerClientes();
        if (_clienteEmEdicao != null) {
          final index = clientesExistentes.indexWhere(
            (c) => c.id == _clienteEmEdicao!.id,
          );
          if (index != -1) {
            clientesExistentes[index] = novoCliente;
            await _escreverClientes(clientesExistentes);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cliente atualizado com sucesso!')),
            );
          }
        } else {
          clientesExistentes.add(novoCliente);
          await _escreverClientes(clientesExistentes);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cliente cadastrado com sucesso!')),
          );
        }
        _carregarListaClientes();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar cliente.')));
      }
    }
  }

  Future<void> _editarCliente(Cliente cliente) async {
    setState(() {
      _clienteEmEdicao = cliente;
      _nomeController.text = cliente.nome;
      _tipoSelecionado = cliente.tipo;
      _cpfCnpjController.text = cliente.cpfCnpj;
      _emailController.text = cliente.email ?? '';
      _telefoneController.text = cliente.telefone ?? '';
      _cepController.text = cliente.cep ?? '';
      _enderecoController.text = cliente.endereco ?? '';
      _bairroController.text = cliente.bairro ?? '';
      _cidadeController.text = cliente.cidade ?? '';
      _ufController.text = cliente.uf ?? '';
    });
  }

  Future<void> _excluirCliente(Cliente cliente) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Exclusão',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Tem certeza que deseja excluir o cliente "${cliente.nome}"?',
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
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Excluir',
                style: TextStyle(color: Color(0xFF3BA9F8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((deveExcluir) async {
      if (deveExcluir == true) {
        try {
          List<Cliente> clientesExistentes = await _lerClientes();
          clientesExistentes.removeWhere((c) => c.id == cliente.id);
          await _escreverClientes(clientesExistentes);
          _carregarListaClientes();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cliente excluído com sucesso!')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao excluir cliente.')));
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
    return File('$path/clientes.json');
  }

  Future<List<Cliente>> _lerClientes() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _escreverClientes(List<Cliente> clientes) async {
    final file = await _localFile;
    final jsonString = json.encode(clientes.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Cliente',
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
                        labelText: 'Tipo *',
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
                      value: _tipoSelecionado,
                      items:
                          <String>['F', 'J'].map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value == 'F' ? 'Física' : 'Jurídica',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'O Tipo é obrigatório'
                                  : null,
                      onChanged:
                          (String? newValue) =>
                              setState(() => _tipoSelecionado = newValue),
                      dropdownColor: Colors.grey[800],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _cpfCnpjController,
                      decoration: InputDecoration(
                        labelText: 'CPF/CNPJ *',
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
                                  ? 'O CPF/CNPJ é obrigatório'
                                  : null,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
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
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
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
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _cepController,
                      decoration: InputDecoration(
                        labelText: 'CEP',
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
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: InputDecoration(
                        labelText: 'Endereço',
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
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _bairroController,
                      decoration: InputDecoration(
                        labelText: 'Bairro',
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
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _cidadeController,
                      decoration: InputDecoration(
                        labelText: 'Cidade',
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
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _ufController,
                      decoration: InputDecoration(
                        labelText: 'UF',
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
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarCliente,
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
                          _clienteEmEdicao == null
                              ? 'Cadastrar Cliente'
                              : 'Salvar Cliente',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                      ),
                    ),
                    if (_clienteEmEdicao != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _clienteEmEdicao = null;
                            _nomeController.clear();
                            _tipoSelecionado = null;
                            _cpfCnpjController.clear();
                            _emailController.clear();
                            _telefoneController.clear();
                            _cepController.clear();
                            _enderecoController.clear();
                            _bairroController.clear();
                            _cidadeController.clear();
                            _ufController.clear();
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
                      'Clientes Cadastrados',
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
                              'Tipo',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CPF/CNPJ',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Telefone',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CEP',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Endereço',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Bairro',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Cidade',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'UF',
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
                            _listaClientes
                                .map(
                                  (cliente) => DataRow(
                                    key: ValueKey(cliente.id),
                                    cells: <DataCell>[
                                      DataCell(
                                        Text(
                                          cliente.id.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.nome,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.tipo == 'F'
                                              ? 'Física'
                                              : 'Jurídica',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.cpfCnpj,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.email ?? '-',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.telefone ?? '-',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.cep ?? '-',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.endereco ?? '-',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.bairro ?? '-',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.cidade ?? '-',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          cliente.uf ?? '-',
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
                                              () => _editarCliente(cliente),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.white70,
                                          ),
                                          onPressed:
                                              () => _excluirCliente(cliente),
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
