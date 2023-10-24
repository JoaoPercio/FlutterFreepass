import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/app/models/document.dart';
import 'package:teste/app/routes/app_routes.dart';
import 'package:teste/app/views/profile_page.dart';
import 'package:teste/provider/users.dart';
import 'home_page.dart';
import 'package:teste/app/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const mainColor = Color(0xff162FB5);

class PassRequestPage extends StatefulWidget {
  @override
  State<PassRequestPage> createState() => _PassRequestPageState();
}

class _PassRequestPageState extends State<PassRequestPage> {
  final _form = GlobalKey<FormState>();

  String name = "";

  String email = "";

  String urlFrenteRG = "";

  String urlVersoRG = "";

  String urlComprovanteResidencia = "";

  String urlAtestadoMatriculaOuCarteiraTrabalho = "";

  Future<UsuarioData> obterDados() async {
    final preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('user_id');

    print(userId);
    final url = 'http://10.0.2.2:5000/api/user/simple/$userId';
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> jsonResponse =
          json.decode(utf8.decode(response.bodyBytes));
      print("Pelo menos fez a requisiçao");
      return UsuarioData.fromJson(jsonResponse);
    }
    throw Exception('Erro ao buscar os dados do usuário');
  }

  void objeto() async {
    Future<UsuarioData> usuariodata = obterDados();
    UsuarioData usuario = await usuariodata;
    print(usuario.email);

    email = usuario.email ?? "email";
    name = usuario.nome_Completo ?? "name";
    print(email);
    print(name);
  }

  void solicitarPasse() async {
    final preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('user_id');
    final url = 'http://10.0.2.2:5000/api/user/solicitarPasse/$userId';
    print(userId);

    DocumentData frenteRG = DocumentData(nome: 'Frente RG', url: urlFrenteRG);
    DocumentData versoRG = DocumentData(nome: 'Verso RG', url: urlVersoRG);
    DocumentData comprovanteResidencia = DocumentData(
        nome: 'Comprovante de Residencia', url: urlComprovanteResidencia);
    DocumentData atestadoMatriculaOuContratoTrabalho = DocumentData(
        nome: 'Atestado de Matricula ou carteira de Trabalho',
        url: urlAtestadoMatriculaOuCarteiraTrabalho);

    List<DocumentData> data = [
      frenteRG,
      versoRG,
      comprovanteResidencia,
      atestadoMatriculaOuContratoTrabalho
    ];

    var body = jsonEncode(data);
    print('json: $body');
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 204) {
      print("Pelo menos fez a requisição");
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Solicitação de Passe Realizada'),
                content: Text('Aguarde a avaliação dos Documentos!'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppRoutes.HOME,
                          arguments: "1",
                        );
                      },
                      child: Text('Voltar'))
                ],
              ));
    }

    if (response.statusCode == 400) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Solicitação de Passe Inválida'),
                content:
                    Text('Aguarde a avaliação dos Documentos já enviados!'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppRoutes.HOME,
                          arguments: "1",
                        );
                      },
                      child: Text('Voltar'))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Users users = Provider.of(context);
    final user_id = ModalRoute.of(context)?.settings.arguments as String;

    objeto();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: mainColor),
              currentAccountPicture: SizedBox(child: Avatar()),
              accountName: Text(name),
              accountEmail: Text(email),
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              subtitle: Text('Tela de Início'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.HOME,
                  arguments: user_id,
                );
              },
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: Icon(Icons.qr_code_2_rounded),
              title: Text('Solicitar Passes'),
              subtitle: Text('Solicite Seus Passes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: Icon(Icons.manage_accounts),
              title: Text('Perfil'),
              subtitle: Text('Informações do Perfil'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.PROFILE,
                  arguments: user_id,
                );
              },
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: Icon(Icons.help),
              title: Text('Ajuda'),
              subtitle: Text('Saiba Mais'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.HELP,
                  arguments: user_id,
                );
              },
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              subtitle: Text('Finalizar Sessão'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.LOGIN);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        title: const Text('Solicitar Passe'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          child: Form(
            key: _form,
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(
                      'COLOQUE O URL DOS SEUS DOCUMENTOS SALVOS EM UM DRIVE PÚBLICO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                      textAlign: TextAlign.center,
                    )),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Frente RG',
                  ),
                  validator: (value) {
                    if (!value.toString().isValidUrl()) {
                      return 'URL inválido!';
                    }

                    return null;
                  },
                  onSaved: (value) => urlFrenteRG = value.toString(),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Verso RG',
                  ),
                  validator: (value) {
                    if (!value.toString().isValidUrl()) {
                      return 'URL inválido!';
                    }

                    return null;
                  },
                  onSaved: (value) => urlVersoRG = value.toString(),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Comprovante de Residencia',
                  ),
                  validator: (value) {
                    if (!value.toString().isValidUrl()) {
                      return 'URL inválido!';
                    }

                    return null;
                  },
                  onSaved: (value) =>
                      urlComprovanteResidencia = value.toString(),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Atestado de Matricula ou Contrato de Trabalho',
                  ),
                  validator: (value) {
                    if (!value.toString().isValidUrl()) {
                      return 'URL inválido!';
                    }

                    return null;
                  },
                  onSaved: (value) =>
                      urlAtestadoMatriculaOuCarteiraTrabalho = value.toString(),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(const Size(270, 50))),
                  onPressed: () {
                    final isValid = _form.currentState!.validate();

                    if (isValid) {
                      _form.currentState!.save();
                      solicitarPasse();
                    }
                  },
                  child: Text(
                    'Solicitar Passe',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//validator of url
extension UrlValidator on String {
  bool isValidUrl() {
    return RegExp(r'^(http(s)?://)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$')
        .hasMatch(this);
  }
}
