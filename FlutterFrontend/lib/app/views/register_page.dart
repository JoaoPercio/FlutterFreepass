import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/app/models/user.dart';
import 'package:teste/app/routes/app_routes.dart';
import 'package:teste/provider/users.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  bool? categoriaPasse = true;
  bool? motociclista = false;
  bool? badRequest = false;

  var maskFormatterCPF = new MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var maskFormatterPhone = new MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var maskFormatterCEP = new MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  final Map<String, String> _formData = {};

  void submit() async {
    const url = 'http://10.0.2.2:5000/api/user';
    badRequest = false;

    Map<String, dynamic> data = {
      'nome_Completo': _formData['nome_completo'],
      'telefone': _formData['telefone'],
      'email': _formData['email'],
      'senha': _formData['senha'],
      'cpf': _formData['cpf'],
      'passe_Categoria': categoriaPasse,
      'motociclista': motociclista,
      'documentos': [
        {
          'nome': 'Frente RG',
          'url': _formData['frenteRG'],
          'isPasse': false,
        },
        {
          'nome': 'Verso RG',
          'url': _formData['versoRG'],
          'isPasse': false,
        },
        {
          'nome': 'Comprovante de Residencia',
          'url': _formData['comprovanteResidencia'],
          'isPasse': false,
        },
        {
          'nome': 'Atestado de Matricula ou carteira de Trabalho',
          'url': _formData['atestadoMatriculaContratoTrabalho'],
          'isPasse': false,
        }
      ],
      'endereco': {
        'cep': _formData['cep'],
        'estado': 'Santa Catarina',
        'cidade': _formData['cidade'],
        'bairro': _formData['bairro'],
        'logradouro': _formData['logradouro'],
        'complemento': _formData['complemento'],
        'numero': _formData['numero'],
      },
    };
    var body = json.encode(data);
    print(body);
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    print(response.body);
    if (response.statusCode == 200) {
      print("Pelo menos fez a requisiçao");
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Usuário Cadastrado com Sucesso!'),
                content:
                    Text('Pressione o botão para retornar a tela de Login.'),
                actions: [
                  TextButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.LOGIN);
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Voltar'))
                ],
              ));
    }

    if (response.statusCode == 400) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Usuário Não Cadastrado!'),
                content: Text('E-mail ou CPF já cadastrados.'),
                actions: [
                  TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Voltar'))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 30),
                  child: const Text(
                    'Free Ferry',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 5),
                        child: Text(
                          'Informe Seus Dados Pessoais',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidName()) {
                            return 'Nome Completo inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['nome_completo'] = value!;
                        },
                      ),
                      TextFormField(
                        inputFormatters: [maskFormatterCPF],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          hintText: '123.456.789-12',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidCPF()) {
                            return 'CPF inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['cpf'] = value!;
                        },
                      ),
                      TextFormField(
                        inputFormatters: [maskFormatterPhone],
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          hintText: '(99) 99999-9999',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidPhone()) {
                            return 'Telefone inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['telefone'] = value!;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: Text(
                          'Informe Seus Dados de Endereço',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                        ),
                        menuMaxHeight: 300,
                        items: const [
                          DropdownMenuItem(
                              child: Text('Itajaí'), value: 'Itajaí'),
                          DropdownMenuItem(
                              child: Text('Navegantes'), value: 'Navegantes'),
                        ],
                        onChanged: (value) {
                          _formData['cidade'] = value!;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Cidade inválida.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['cidade'] = value!;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Bairro',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidName()) {
                            return 'Bairro inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['bairro'] = value!;
                        },
                      ),
                      TextFormField(
                        inputFormatters: [maskFormatterCEP],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CEP',
                          hintText: '12345-678',
                        ),
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return 'CEP inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['cep'] = value!;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Logradouro',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidName()) {
                            return 'Logradouro inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['logradouro'] = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: '',
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Complemento (opcional)',
                        ),
                        onSaved: (value) {
                          _formData['complemento'] = value!;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Número',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidNumber()) {
                            return 'Número inválido.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['numero'] = value!;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: Text(
                          'Informe Seus Dados da Conta',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'exemplo@exemplo.com'),
                        validator: (value) {
                          if (!value.toString().isValidEmail()) {
                            return 'E-mail inválido.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _formData['email'] = value!;
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidPassword()) {
                            return 'Senha inválida.';
                          }

                          return null;
                        },
                        onChanged: (value) {
                          _formData['senha'] = value;
                        },
                        onSaved: (value) {
                          _formData['senha'] = value!;
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirme sua Senha',
                        ),
                        validator: (value) {
                          if (_formData['senha'] !=
                              _formData['senhaConfirmada']) {
                            return 'As senhas não são iguais.';
                          }

                          return null;
                        },
                        onChanged: (value) {
                          _formData['senhaConfirmada'] = value;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: Text(
                          'Informações do Passe',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                                title: Text('Estudante'),
                                value: true,
                                groupValue: categoriaPasse,
                                onChanged: (value) {
                                  setState(() {
                                    categoriaPasse = value;
                                  });
                                }),
                          ),
                          Expanded(
                            child: RadioListTile(
                                title: Text('Trabalhador'),
                                value: false,
                                groupValue: categoriaPasse,
                                onChanged: (value) {
                                  setState(() {
                                    categoriaPasse = value;
                                  });
                                }),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                                title: Text('Pedestre'),
                                value: false,
                                groupValue: motociclista,
                                onChanged: (value) {
                                  setState(() {
                                    motociclista = value;
                                  });
                                }),
                          ),
                          Expanded(
                            child: RadioListTile(
                                title: Text('Motociclista'),
                                value: true,
                                groupValue: motociclista,
                                onChanged: (value) {
                                  setState(() {
                                    motociclista = value;
                                  });
                                }),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: Text(
                          'Insira os URLs dos Documentos (salvos em um drive público)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
                        onSaved: (value) =>
                            _formData['frenteRG'] = value.toString(),
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
                        onSaved: (value) =>
                            _formData['versoRG'] = value.toString(),
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
                        onSaved: (value) => _formData['comprovanteResidencia'] =
                            value.toString(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText:
                              'Atestado de Matricula ou Contrato de Trabalho',
                        ),
                        validator: (value) {
                          if (!value.toString().isValidUrl()) {
                            return 'URL inválido!';
                          }

                          return null;
                        },
                        onSaved: (value) =>
                            _formData['atestadoMatriculaContratoTrabalho'] =
                                value.toString(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            minimumSize:
                                MaterialStateProperty.all(const Size(200, 50)),
                            backgroundColor:
                                MaterialStateProperty.all(mainColor)),
                        child: const Text(
                          'REGISTRAR',
                          style: TextStyle(fontSize: 30),
                        ),
                        onPressed: () {
                          final isValid = _form.currentState!.validate();

                          if (isValid) {
                            _form.currentState!.save();
                            submit();
                          }
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já possui uma conta? ',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      InkWell(
                        child: Text(
                          'Conecte-se',
                          style: TextStyle(fontSize: 15, color: mainColor),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.LOGIN);
                        },
                      )
                    ],
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

//validator of url
extension UrlValidator on String {
  bool isValidUrl() {
    return RegExp(r'^(http(s)?://)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$')
        .hasMatch(this);
  }
}

//validator of name
extension NameValidator on String {
  bool isValidName() {
    return RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿ\s\-]{3,}$').hasMatch(this);
  }
}

//validator of cpf
extension CPFValidator on String {
  bool isValidCPF() {
    return RegExp(r'^\d{3}\.\d{3}\.\d{3}\-\d{2}$').hasMatch(this);
  }
}

//validator of phone number
extension PhoneValidator on String {
  bool isValidPhone() {
    return RegExp(r'^\([1-9]{2}\) [2-9][0-9]{3,4}\-[0-9]{4}$').hasMatch(this);
  }
}

//validator of number
extension NumberValidator on String {
  bool isValidNumber() {
    return RegExp(r'[0-9]').hasMatch(this);
  }
}
