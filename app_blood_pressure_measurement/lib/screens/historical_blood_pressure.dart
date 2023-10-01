import 'package:flutter/material.dart';

import 'chart_wave_form_screen.dart';

class HistoricalBloodPressure extends StatelessWidget {
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue];
  List<Map<String, dynamic>> listaTeste = [
    {
      'data': '25/02/2013',
      'valorDBP': 60,
      'valorSBP': 120,
      'ondaDePressao': [65,71,75,88,96,99,100],
      'frequencia': 1,
    },
    {
      'data': '26/08/2013',
      'valorDBP': 70,
      'valorSBP': 125,
      'ondaDePressao': [70,80,93,91,95,100,120,121,120,110],
      'frequencia': 1,
    },
    {
      'data': '10/09/2013',
      'valorDBP': 60,
      'valorSBP': 120,
      'ondaDePressao': [71,78,82,87,86,82,89,100,101,102],
      'frequencia': 1,
    }
  ];


  
  HistoricalBloodPressure({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.cyanAccent[700],
          title: const Text('HISTÓRICO DE PRESSÃO ARTERIAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18
            ),
          ),
        ),
        body: PageView.builder(
          itemCount: listaTeste.length,
          itemBuilder: (context, index) {
            final invertedIndex = listaTeste.length - 1 - index;
            return Container(
              child: Column(
                children: [
                  Text(listaTeste[invertedIndex]['data']),
                  const SizedBox(height: 20), 
                  Center(
                    child: ChartWaveFormScreen(
                      minBPValue: listaTeste[invertedIndex]['valorDBP']-10, 
                      maxBPValue: listaTeste[invertedIndex]['valorSBP']+10,
                      arrayBP: listaTeste[invertedIndex]['ondaDePressao'],
                      freq: listaTeste[invertedIndex]['frequencia'],
                    ),
                  ),
                ]
              ),
            );
          },
        ),
      ),
    );
  }
}