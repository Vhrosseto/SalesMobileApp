class Produto {
  final int id;
  final String nome;
  final String unidade;
  final double quantidadeEstoque;
  final double precoVenda;
  final int status;
  final double? custo;
  final String? codigoBarra;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarra,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      unidade: json['unidade'],
      quantidadeEstoque: json['quantidadeEstoque'],
      precoVenda: json['precoVenda'],
      status: json['status'],
      custo: json['custo'],
      codigoBarra: json['codigoBarra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'unidade': unidade,
      'quantidadeEstoque': quantidadeEstoque,
      'precoVenda': precoVenda,
      'status': status,
      'custo': custo,
      'codigoBarra': codigoBarra,
    };
  }
}
