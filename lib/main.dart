import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ViaCEP',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const MyHomePage(title: 'ViaCEP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final cepControllerCidade = TextEditingController();
  final cepControllerUF = TextEditingController();
  final cepControllerIBGE = TextEditingController();
  String cep = '';

  Future<void> pesquisaCEP(String cep) async {
    //Url da API
    var url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      // A requisição foi bem-sucedida
      var jsonResponse = jsonDecode(response.body);
      var cidade = jsonResponse['localidade'];
      var uf = jsonResponse['uf'];
      var ibge = jsonResponse['ibge'];

      // Atualiza os valores dos campos de texto
      setState(() {
        cepControllerCidade.text = cidade ?? '';
        cepControllerUF.text = uf ?? '';
        cepControllerIBGE.text = ibge ?? '';
      });
    } else {
      // A requisição falhou

      const SnackBar(content: Text('Erro ao Buscar o CEP, verifique!'));
    }
  }

  //Formatando o CEP
  final cepFormatacao = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {
      '#': RegExp(r'[0-9]'),
    },
  );

  @override
  Widget build(BuildContext context) {
    final tamanhoTela = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          SafeArea(
            child: IconButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              icon: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: SizedBox(
          width: tamanhoTela.width,
          height: tamanhoTela.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                //Campo para adiconar o CEP
                child: TextFormField(
                  onChanged: (value) {
                    //Passo o valor do campo para a var cep
                    cep = value;
                  },
                  inputFormatters: [cepFormatacao],
                  decoration: InputDecoration(
                    isDense: true,
                    label: const Text('Insira o CEP'),
                    suffixIcon: IconButton(
                      onPressed: () {
                        //Chamo a função para buscar na API
                        pesquisaCEP(cep);
                      },
                      icon: const Icon(
                        Icons.search,
                        size: 25,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      //Campo para a Cidade
                      child: TextFormField(
                        controller: cepControllerCidade,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Cidade',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: SizedBox(
                        width: 100,
                        child: Expanded(
                          //Campo para a UF
                          child: TextFormField(
                            controller: cepControllerUF,
                            readOnly: true,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'UF',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Campo para o Código do IBGE
              TextFormField(
                controller: cepControllerIBGE,
                readOnly: true,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Código IBGE',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
