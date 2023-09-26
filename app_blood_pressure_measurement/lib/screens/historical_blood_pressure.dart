import 'package:flutter/material.dart';

import 'chart_wave_form_screen.dart';

class HistoricalBloodPressure extends StatelessWidget {
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue];
  List<Map<String, dynamic>> listaTeste = [
    {
      'data': '25/02/2013',
      'valorDBP': 60,
      'valorSBP': 120,
      'ondaDePressao': [65,70,80,90,91,92,100],
      'frequencia': 1,
    },
    {
      'data': '26/08/2013',
      'valorDBP': 70,
      'valorSBP': 125,
      'ondaDePressao': [70,80,90,91,92,100,120,121,120,110],
      'frequencia': 1,
    },
    {
      'data': '10/09/2013',
      'valorDBP': 60,
      'valorSBP': 120,
      'ondaDePressao': [65,70,80,85,86,82,89,100,101,102],
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
            return Container(
              child: Column(
                children: [
                  Text(listaTeste[index]['data']),
                  const SizedBox(height: 20), 
                  Center(
                    child: ChartWaveFormScreen(
                      minBPValue: listaTeste[index]['valorDBP']-10, 
                      maxBPValue: listaTeste[index]['valorSBP']+10,
                      arrayBP: listaTeste[index]['ondaDePressao'],
                      freq: listaTeste[index]['frequencia'],
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