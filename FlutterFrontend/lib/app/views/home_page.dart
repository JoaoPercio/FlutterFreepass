import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:teste/app/routes/app_routes.dart';
import 'package:teste/app_controller.dart';
import 'package:teste/provider/users.dart';
import 'package:teste/app/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const mainColor = Color(0xff162FB5);

class HomePage extends StatelessWidget {
  String name= "";
  String email= "";
  int passes=23;

  Future<UsuarioData> obterDados() async{
    final preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('user_id');

    print(userId);
    final url = 'http://10.0.2.2:5000/api/user/simple/$userId';
    final response = await http.get(Uri.parse(url),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print("Pelo menos fez a requisiçao");
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
  passes = usuario.passe_Quantidade ?? 0;
  print(passes);
  print(email);
  print(name);
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
                  leading: const Icon(Icons.home),
                  title: const Text('Inicio'),
                  subtitle: const Text('Tela de Início'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(Icons.qr_code_2_rounded),
                  title: const Text('Solicitar Passes'),
                  subtitle: const Text('Solicite Seus Passes'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.PASS_REQUEST,
                      arguments: user_id,
                    );
                  },
                ),
                ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(Icons.manage_accounts),
                  title: const Text('Perfil'),
                  subtitle: const Text('Informações do Perfil'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.PROFILE,
                      arguments: user_id,
                    );
                  },
                ),
                ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(Icons.help),
                  title: const Text('Ajuda'),
                  subtitle: const Text('Saiba Mais'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.HELP,
                      arguments: user_id,
                    );
                  },
                ),
                ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  subtitle: const Text('Finalizar Sessão'),
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
            title: const Text('Início'),
          ),
          body: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Passes',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: mainColor),
                          ))),
                  Expanded(
                    flex: 4,
                    child: QrImageView(data: email),
                    //qr code here
                  ),
                  Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Quantidade de Passes Disponíveis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          passes.toString(),
                          style: const TextStyle(fontSize: 50),
                        ),
                      )),
                ],
              )));
    }
    );

    }
}

class CustomSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: AppController.instance.isDarkTheme,
        onChanged: (value) {
          AppController.instance.changeTheme();
        });
  }
}

class Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user_id = ModalRoute.of(context)?.settings.arguments as String;
    final avatar = Provider.of<Users>(context).byId(user_id)!.avatarUrl.isEmpty
        ? const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blueAccent,
            child: Icon(
              Icons.person,
              size: 70,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                Provider.of<Users>(context).byId(user_id)!.avatarUrl,
              ),
            ),
          );
    return avatar;
  }
}
