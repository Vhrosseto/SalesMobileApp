class Cliente {
  int id; 
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

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
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

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int, 
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
