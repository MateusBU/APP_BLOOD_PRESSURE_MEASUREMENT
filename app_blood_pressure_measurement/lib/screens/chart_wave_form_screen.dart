import 'package:app_blood_pressure_measurement/models/deviceBloodPressure.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class ChartWaveFormScreen extends StatelessWidget {

  int minBPValue = 0;
  int maxBPValue = 0;
  List<int> arrayBP = [];
  int freq = 0;

  ChartWaveFormScreen({
    super.key,
    required this.minBPValue,
    required this.maxBPValue,
    required this.arrayBP,
    required this.freq,   
    });

  List<FlSpot> getSpotForChart(){
    int frequency = 0;
    List<FlSpot> spot = [];
    for(int index = 0; index < arrayBP.length; index++){
      spot.add(FlSpot(arrayBP[index]/1.0, frequency/1.0));
      frequency += freq;
    }
    return spot;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
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
        maxX: 6,    //todo ver o máximo
        minY: minBPValue/1.0,
        maxY: maxBPValue/1.0,
        lineBarsData: [
          LineChartBarData(
            spots: getSpotForChart(),
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
    );
  }
}