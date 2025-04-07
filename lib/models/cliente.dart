class Cliente {
  int id; // Alterado para int
  String nome;
  String tipo;
  String cpfCnpj;
  String? email;
  String? telefone;
  String? cep;
  String? endereco;
  String? bairro;
  String? cidade;
  String? uf;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
  });

  // Método para converter um objeto Cliente em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Mantém como está, o json.encode lidará com o tipo
      'nome': nome,
      'tipo': tipo,
      'cpfCnpj': cpfCnpj,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
    };
  }

  // Método para criar um objeto Cliente a partir de um mapa JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int, // Faz o cast para int ao ler do JSON
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      cpfCnpj: json['cpfCnpj'] as String,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      cep: json['cep'] as String?,
      endereco: json['endereco'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['uf'] as String?,
    );
  }
}
