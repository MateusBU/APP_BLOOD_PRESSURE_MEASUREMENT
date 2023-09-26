import 'package:flutter/material.dart';

class HistoricalBloodPressure extends StatelessWidget {
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue];
  
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
          itemCount: colors.length,
          itemBuilder: (context, index) {
            return Container(
              color: colors[index],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("data"),
                  const SizedBox(height: 200,),
                  Center(
                    child: Text(
                      'Página ${index + 1}',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}