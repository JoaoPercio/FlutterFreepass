import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/app/routes/app_routes.dart';
import 'package:teste/provider/users.dart';
import 'home_page.dart';
import 'package:teste/app/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const mainColor = Color(0xff162FB5);

class PassRequestPage extends StatelessWidget {
  String name= "";
  String email= "";
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
  void objeto() async{
    Future<UsuarioData> usuariodata=  obterDados();
    UsuarioData usuario= await usuariodata;
    print(usuario.email);

    email = usuario.email ?? "email";
    name = usuario.nome_Completo ?? "name";
    print(email);
    print(name);
  }


  @override
  Widget build(BuildContext context) {
    final Users users = Provider.of(context);
    final user_id = ModalRoute.of(context)?.settings.arguments as String;
    objeto();
    return Scaffold(
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
          child: Column(
            children: [
              Expanded(child: Container(color: Colors.red)),
              Expanded(child: Container(color: Colors.green)),
              Expanded(child: Container(color: Colors.amber)),
            ],
          ),
        ),
      ),
    );
  }
}
