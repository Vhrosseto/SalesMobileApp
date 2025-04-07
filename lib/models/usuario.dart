class Usuario {
  final int id;
  final String nome;
  final String senha;

  Usuario({
    required this.id,
    required this.nome,
    required this.senha,
  });

  // Método para criar um objeto Usuario a partir de um mapa (JSON)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      senha: json['senha'],
    );
  }

  // Método para converter o objeto Usuario em um mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
    };
  }
}