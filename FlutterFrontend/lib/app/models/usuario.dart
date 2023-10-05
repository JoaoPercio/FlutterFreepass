class UsuarioData {
  int? id;
  String? nome_Completo;
  String? email;
  String? senha;
  int? passe_Quantidade;

  UsuarioData(
      {this.id, this.nome_Completo, this.email, this.senha, this.passe_Quantidade});

  factory UsuarioData.fromJson(Map<String, dynamic> json) {
    return UsuarioData(
      id: json['id'],
      nome_Completo: json['nome_Completo'],
      email: json['email'],
      senha: json['senha'],
      passe_Quantidade: json['passe_Quantidade'],
    );
  }
}