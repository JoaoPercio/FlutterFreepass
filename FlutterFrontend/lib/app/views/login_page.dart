// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/app/exceptions/NoRegisteredUsersException.dart';
import 'package:teste/app/exceptions/PasswordNotFoundException.dart';
import 'package:teste/app/exceptions/EmailNotFoundException.dart';
import 'package:teste/app/models/user.dart';
import 'package:teste/app/routes/app_routes.dart';
import 'package:teste/provider/users.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste/app/views/api.dart';

const mainColor = Color(0xff162FB5);

class LoginPage extends StatelessWidget {
  final _form = GlobalKey<FormState>();
  //usando as variaveis email e senha para passar no JSON
  String email = '';
  String password = '';
  bool invalidEmail = false;
  bool invalidPassword = false;
  late User? user;

  // funçao que faz a requsiçao pro back end
  Future<int> submit() async {
    //url da requisiçao
    const url = 'http://10.0.2.2:5000/api/user/login';
    //criando um JSON para requisiçao
    print('O valor de email e $email');
    print('O valor de password e $password');

    var body = json.encode({'email': email, 'password': password});
    print(body);
    //fazendo a requisiçao
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    // vendo o id o usuario retornado
    print(response.body);
    // se a requisiçao foi ok status 200
    if (response.statusCode == 200) {
      //salvando o id do usuario para outras requisiçoes no aplicativo, exemplo de como usar o id_salvo lá na funçao excluir usuario
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('user_id', response.body);
      print("Pelo menos fez a requisiçao");
      return 1;
    }
    // se o status é 500 o cadastro do mano ainda nao foi validado
    if (response.statusCode == 500) {
      return 2;
    }
    //se deu outro status retorna 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Free Ferry',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ),
                    )),
                    Expanded(
                      flex: 2,
                      child: Form(
                        key: _form,
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  border: OutlineInputBorder()),
                              onChanged: (value) {
                                email = value;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                  labelText: 'Senha',
                                  border: OutlineInputBorder()),
                              onChanged: (value) {
                                password = value;
                              },
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0))),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(200, 50)),
                                    backgroundColor:
                                        MaterialStateProperty.all(mainColor)),
                                onPressed: () {
                                  //chamando a funçao de login
                                  submit().then((int valorRetornado) {
                                    print(
                                        "O valor retornado pela função submit() é: $valorRetornado");

                                    if (valorRetornado == 1) {
                                      Navigator.of(context)
                                          .pushReplacementNamed(AppRoutes.HOME,
                                              arguments: "1");
                                    } else if (valorRetornado == 2) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text(
                                                    'Seu Cadastro Ainda não Foi Aprovado!'),
                                                content: Text(
                                                    'Favor olhar analizar em seu email se seu cadastro ja foi aprovado.'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Voltar'))
                                                ],
                                              ));
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text(
                                                    'email ou senha incorreto!'),
                                                content: Text(
                                                    'Favor verificar seu email e senha.'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Voltar'))
                                                ],
                                              ));
                                    }
                                  }).catchError((error) {
                                    // Lida com erros, se houver algum
                                    print("Ocorreu um erro: $error");
                                  });
                                },
                                child: const Text(
                                  'ENTRAR',
                                  style: TextStyle(fontSize: 30),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Não tem uma conta? ',
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                          InkWell(
                            child: Text(
                              'Registre-se',
                              style: TextStyle(fontSize: 15, color: mainColor),
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.REGISTER);
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: Image.asset(
                        'assets/images/logo_governo.png',
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }
}
