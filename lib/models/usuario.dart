class Usuario {
  final int id;
  final String nome;
  final String senha;

  Usuario({
    required this.id,
    required this.nome,
    required this.senha,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      senha: json['senha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
    };
  }
}