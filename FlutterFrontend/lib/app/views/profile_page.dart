import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/app/models/user.dart';
import 'package:teste/app/routes/app_routes.dart';
import 'package:teste/provider/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'package:teste/app/models/usuario.dart';
import 'dart:convert';

class ProfilePage extends StatelessWidget {
  final _form = GlobalKey<FormState>();
  String name= "";
  String email= "";
  String password= "";
  String newEmail = "";
  String newPassword = "";
  //funçao para excluir um usuario com a requisiçao
  void excluir() async{
    final preferences = await SharedPreferences.getInstance();
     String? userId = preferences.getString('user_id');

    print(userId);
    final url = 'http://10.0.2.2:5000/api/user/$userId';
    final response = await http.delete(Uri.parse(url),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      print("Pelo menos fez a requisiçao");
    }
  }

  Future<UsuarioData> obterDados() async{
    final preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('user_id');

    final url = 'http://10.0.2.2:5000/api/user/simple/$userId';
    final response = await http.get(Uri.parse(url),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return UsuarioData.fromJson(jsonResponse);
    }
    throw Exception('Erro ao buscar os dados do usuário');
  }
  Future objeto() async{
    Future<UsuarioData> usuariodata=  obterDados();
    UsuarioData usuario= await usuariodata;
    print(usuario.email);

    email = usuario.email ?? "email";
    name = usuario.nome_Completo ?? "name";
    password = usuario.senha ?? "name";
  }
  void editar() async{
    final preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('user_id');
    final url = 'http://10.0.2.2:5000/api/user/$userId';
    print(userId);
    var body = json
        .encode({'id':userId,'email': newEmail, 'senha': newPassword});
    final response = await http.put(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    print(response.body);
    // se a requisiçao foi ok status 200
    if (response.statusCode == 200) {
      print("Pelo menos fez a requisiçao");
    }
  }
  @override
  Widget build(BuildContext context) {
    final Users users = Provider.of(context);
    final user_id = ModalRoute.of(context)?.settings.arguments as String;
    return FutureBuilder(
        future: objeto(), // Chama a função objeto() aqui
    builder: (context, snapshot) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        endDrawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: mainColor),
                currentAccountPicture: SizedBox(
                  child: Avatar(),
                ),
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
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.PASS_REQUEST,
                    arguments: user_id,
                  );
                },
              ),
              ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                leading: Icon(Icons.manage_accounts),
                title: Text('Perfil'),
                subtitle: Text('Informações do Perfil'),
                onTap: () {
                  Navigator.pop(context);
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
          title: const Text('Perfil'),
        ),
        body: SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Avatar(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          name,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Form(
                        key: _form,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(labelText: 'E-mail'),
                              validator: (value) {
                                if (!value.toString().isValidEmail()) {
                                  return 'E-mail inválido.';
                                }

                                if (users.getUserByEmail(value!) != null) {
                                  return 'E-mail já cadastrado.';
                                }

                                return null;
                              },
                              onSaved: (value) => newEmail = value.toString(),
                            ),
                            TextFormField(
                              initialValue: password,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(labelText: 'Senha'),
                              validator: (value) {
                                if (!value.toString().isValidPassword()) {
                                  return 'Senha inválida.\nPelo menos 3 caracteres. Somente letras e números.';
                                }

                                return null;
                              },
                              onSaved: (value) => newPassword = value.toString(),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(270, 50))),
                            onPressed: () {
                              final isValid = _form.currentState!.validate();

                              if (isValid) {
                                editar();
                                _form.currentState!.save();
                                Provider.of<Users>(context, listen: false).put(
                                  User(
                                    id: users.byId(user_id)!.id,
                                    name: users.byId(user_id)!.name,
                                    email: newEmail,
                                    password: newPassword,
                                    passes: users.byId(user_id)!.passes,
                                    avatarUrl: users.byId(user_id)!.avatarUrl,
                                  ),
                                );
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Usário Alterado'),
                                      content: Text(
                                          'Os dados do usuário foram alterados!'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Voltar'))
                                      ],
                                    ));
                              }
                            },
                            child: Text(
                              'Salvar Alterações',
                              style: TextStyle(fontSize: 30),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(270, 50)),
                                backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Excluir Usuário'),
                                    content: Text('Tem certeza?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Não'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Sim'),
                                        onPressed: () {
                                          excluir();
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                              AppRoutes.LOGIN);
                                        },
                                      ),
                                    ],
                                  ));
                            },
                            child: Text(
                              'Excluir Usuário',
                              style: TextStyle(fontSize: 30),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            )),
      );
    }
    );

  }
}

//validator of email
extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

//only letters and numbers on passwords
extension PasswordValidator on String {
  bool isValidPassword() {
    return RegExp(r'^[A-Za-z0-9]{3,}$').hasMatch(this);
  }
}
