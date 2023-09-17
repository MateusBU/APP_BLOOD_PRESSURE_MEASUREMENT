import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BloodPressureScreen extends StatefulWidget {

  final bool _isValuesReady = false;
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.cyanAccent[700],
          title: const Text('Line Chart Example'),
        ),
        body:widget._isValuesReady ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("GRÁFICO"),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 400.0, // Specify width
                  height: 400.0, // Specify height
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        show: false,
                      ),
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: const Color(0xff37434d),
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 3),
                            const FlSpot(1, 1),
                            const FlSpot(2, 4),
                            const FlSpot(3, 2),
                            const FlSpot(4, 5),
                            const FlSpot(5, 1),
                          ],
                          isCurved: true,
                          color: const Color.fromARGB(255, 256, 24, 47),
                          dotData: const FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Row(
              children: [
                ElevatedButton(
                  onPressed: null,
                  child: Text("Salvar"),
                ),
              ],
            ),
          ],
        )
        :
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("ESPERANDO PELOS VALORES",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color:  Color.fromARGB(255, 73, 2, 111),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100,),
              CircularProgressIndicator(),
            ]
          ),
        ),
      ),
    );
  }
}