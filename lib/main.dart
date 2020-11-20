import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://economia.awesomeapi.com.br/json/all";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final brlController = TextEditingController();
  final dolController = TextEditingController();
  final eurController = TextEditingController();

  double dol, eur;

  void _clearAll() {
    brlController.text = "";
    dolController.text = "";
    eurController.text = "";
  }

  void _brlChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double brl = double.parse(text);
    dolController.text = (brl / dol).toStringAsFixed(2);
    eurController.text = (brl / eur).toStringAsFixed(2);
  }

  void _dolChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dol = double.parse(text);
    brlController.text = (dol * this.dol).toStringAsFixed(2);
    eurController.text = (dol * this.dol / eur).toStringAsFixed(2);
  }

  void _eurChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double eur = double.parse(text);
    brlController.text = (eur * this.eur).toStringAsFixed(2);
    dolController.text = (eur * this.eur / dol).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          title: Text("Converter"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Loading data...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error while loading data.",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 25.0),
                            textAlign: TextAlign.center));
                  } else {
                    dol = double.parse(snapshot.data["USD"]["bid"]);
                    eur = double.parse(snapshot.data["EUR"]["bid"]);
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextField(
                              "BRL", "R\$", brlController, _brlChanged),
                          Divider(),
                          buildTextField(
                              "Dollars", "US\$", dolController, _dolChanged),
                          Divider(),
                          buildTextField(
                              "Euros", "€", eurController, _eurChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

class Palette {
  static final Color background = Color(0xff171717);
}
