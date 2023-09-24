import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/deviceBloodPressure.dart';

enum BluetoothData{
  stx,
  addressEsp,
  addressApp,
  command,
  dataBluetooth,
  checksum,
  etx,
  done,
} 

class BloodPressureScreen extends StatefulWidget {

  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {


  late Stream<List<int>> _valueWaveFormStream;
  List<int> _currentValueWaveForm = [];
  final List<int> _dataWaveForm = [];
  bool _isValuesReady = false;

  @override
  void initState(){
    super.initState();
    startNotifierDataWaveForm();
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if(_currentValueWaveForm.isNotEmpty){
          verifyReceiveDatWaveForm(_currentValueWaveForm);
        }
      });
  }

  startNotifierDataWaveForm(){
    for(BluetoothCharacteristic c in DeviceBloodPressure.getInstance().getServiceDevices()){
      if(c.characteristicUuid.toString() == "86d3ac32-8756-11e7-bb31-be2e44b06b34"){
        _valueWaveFormStream = c.lastValueStream;
        _valueWaveFormStream.listen((value) {
          setState(() {
            _currentValueWaveForm = value;
          });
        });
      }
    }
  }

  void verifyReceiveDatWaveForm(List<int> currentValueWaveForm){
    BluetoothData blueData = BluetoothData.stx;
    int indexDataArray = _dataWaveForm.length, 
        checksum = 0, 
        index = 0,
        commandData = 0;
    String checksumString = '';

    while(blueData != BluetoothData.done){
      switch(blueData){
        case BluetoothData.stx:
          if(_currentValueWaveForm[index] == 2){
            blueData = BluetoothData.addressEsp;
            index++;
          }
          else{
          blueData = BluetoothData.done;
          }
        break;

        case BluetoothData.addressEsp:
          checksum ^= _currentValueWaveForm[index];
          if(_currentValueWaveForm[index] == 98){
            blueData = BluetoothData.addressApp;
            index++;
          }
          else{
          blueData = BluetoothData.done;
          }
        break;

        case BluetoothData.addressApp:
          checksum ^= _currentValueWaveForm[index];
          if(_currentValueWaveForm[index] == 112){
            blueData = BluetoothData.command;
            index++;
          }
        break;

        case BluetoothData.command:
          checksum ^= _currentValueWaveForm[index];
            if(_currentValueWaveForm[index] == 70 || _currentValueWaveForm[index] == 71){ //F
              commandData = _currentValueWaveForm[index];
              blueData = BluetoothData.dataBluetooth;
            }
            else{
              blueData = BluetoothData.done;
            }
            index++;
        break;

        case BluetoothData.dataBluetooth:
          checksum ^= _currentValueWaveForm[index];
          if(_currentValueWaveForm[index] != 91 && _currentValueWaveForm[index] != 93) {
            // [ e ]
            _dataWaveForm[indexDataArray] = _currentValueWaveForm[index];
          }
          else if(_currentValueWaveForm[index] == 93){
            blueData = BluetoothData.checksum;
          }
          index++;
        break;

        case BluetoothData.checksum:
          checksumString = checksum.toRadixString(16);
          if(checksumString[0].toUpperCase().codeUnitAt(0) != _currentValueWaveForm[index]){
            blueData = BluetoothData.done;
          }
          index++;
          if(checksumString[1].toUpperCase().codeUnitAt(0) != _currentValueWaveForm[index]){
            blueData = BluetoothData.done;
          }
          index++;
          blueData = BluetoothData.etx;
        break;

        case BluetoothData.etx:
          if(_currentValueWaveForm[index] == 3){
            if(commandData == 70){
              DeviceBloodPressure.getInstance().setValueWaveForm(_dataWaveForm);
              _dataWaveForm.clear();
            }
            else if (commandData == 71){
              setState(() {
                _isValuesReady = true;
              });
            }
          }
          blueData = BluetoothData.done;
          break;
        
        default:
          blueData = BluetoothData.done;
          break;
      }
    }   
  }

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
        body:_isValuesReady ? Column(
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