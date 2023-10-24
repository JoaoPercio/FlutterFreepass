class DocumentData {
  String? nome;
  String? url;

  DocumentData({this.nome, this.url});

  DocumentData.fromJson(Map<String, dynamic> json)
      : nome = json['nome'],
        url = json['url'];

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'url': url,
    };
  }
}
