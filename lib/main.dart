import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AhorcadoApp());
}

class AhorcadoApp extends StatelessWidget {
  const AhorcadoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ahorcado Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AhorcadoHomePage(),
    );
  }
}

class AhorcadoHomePage extends StatefulWidget {
  const AhorcadoHomePage({Key? key}) : super(key: key);

  @override
  _AhorcadoHomePageState createState() => _AhorcadoHomePageState();
}

class _AhorcadoHomePageState extends State<AhorcadoHomePage> {

  String palabraSeleccionada = '';
  String palabraVisible = '';
  List<String> letrasUsadas = [];

  int intentos = 6;

  @override
  void initState() {
    super.initState();
    iniciarJuego();
  }

  Future<void> iniciarJuego() async {
    palabraSeleccionada = await obtenerPalabraAleatoria();
    setState(() {
      palabraVisible = palabraSeleccionada.replaceAll(RegExp(r'\w'), '_');
    });
  }

  static Future<String> obtenerPalabraAleatoria() async {
    final response = await http.get(Uri.parse('https://random-word-api.herokuapp.com/word'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse[0]);
      return jsonResponse[0];
    } else {
      throw Exception('Error al obtener palabra aleatoria.');
    }
  }

  void reiniciar() {
    setState(() {
      iniciarJuego();
      letrasUsadas.clear();
      intentos = 6;
    });
  }

  void procesarLetra(String letra) {
    if (letrasUsadas.contains(letra) || intentos < 1) return;

    setState(() {
      letrasUsadas.add(letra);

      if (palabraSeleccionada.contains(letra)) {
        var nuevaPalabraVisible = List<String>.from(palabraVisible.split(''));
        for (int i = 0; i < palabraSeleccionada.length; i++) {
          if (palabraSeleccionada[i] == letra) {
            nuevaPalabraVisible[i] = letra;
          }
        }
        palabraVisible = nuevaPalabraVisible.join();
      } else {
        intentos--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorcado en Flutter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              palabraVisible,
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 20),
            Text(
              'Intentos restantes: $intentos',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map<Widget>((String letra) {
                return ElevatedButton(
                  onPressed: () => procesarLetra(letra.toLowerCase()),
                  child: Text(letra),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: letrasUsadas.map<Widget>((String letra) {
                return Chip(label: Text(letra.toUpperCase()));
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: reiniciar,
              child: const Text(
                'Reiniciar juego',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}