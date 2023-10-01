import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/deviceBloodPressure.dart';
import 'chart_wave_form_screen.dart';

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

  int minBPValue = 0;
  int maxBPValue = 0;
  List<int> arrayBP = [];
  int freq = 0;

  final List<int> _crc32Table = [];
  int crc32 = 0xFFFFFFFF;

  @override
  void initState(){
    super.initState();
    startNotifierDataWaveForm();
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if(_currentValueWaveForm.isNotEmpty){
          verifyReceiveDatWaveForm(_currentValueWaveForm);
        }
    });
    protocolCrc32InitTable();
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

    /*---CRC32--- */
  // Inicialização da tabela de lookup
  void protocolCrc32InitTable(){
      int crc;
      for (int i = 0; i < 256; i++) {
          crc = i;
          for (int j = 0; j < 8; j++) {
              if ((crc & 1) >= 1) {
                  crc = (crc >> 1) ^ 0xEDB88320; // Valor mágico para o CRC-32
              } else {
                  crc = crc >> 1;
              }
          }
          _crc32Table.add(crc);
      }
  }

  void protocolcrc32Calculate(int crc, int value) {
      crc32 = (crc >> 8) ^ _crc32Table[(crc ^ value) & 0xFF];
  }

  void verifyReceiveDatWaveForm(List<int> currentValueWaveForm){
    BluetoothData blueData = BluetoothData.stx;
    int indexDataArray = _dataWaveForm.length, 
        checksum = 0, 
        index = 0,
        commandData = 0,
        dataFreq = 0;
    crc32 = 0xFFFFFFFF;//, decimalNumber = 255;
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
          protocolcrc32Calculate(crc32,_currentValueWaveForm[index]);
          if(_currentValueWaveForm[index] == 98){
            blueData = BluetoothData.addressApp;
            index++;
          }
          else{
          blueData = BluetoothData.done;
          }
        break;

        case BluetoothData.addressApp:
          protocolcrc32Calculate(crc32,_currentValueWaveForm[index]);
          if(_currentValueWaveForm[index] == 112){
            blueData = BluetoothData.command;
            index++;
          }
        break;

        case BluetoothData.command:
          protocolcrc32Calculate(crc32,_currentValueWaveForm[index]);
            if(_currentValueWaveForm[index] == 71 || _currentValueWaveForm[index] == 72){ //G  H
              commandData = _currentValueWaveForm[index];
              blueData = BluetoothData.dataBluetooth;
            }
            else{
              blueData = BluetoothData.done;
            }
            index++;
        break;

        case BluetoothData.dataBluetooth:
          protocolcrc32Calculate(crc32,_currentValueWaveForm[index]);
          if(_currentValueWaveForm[index] != 91 && _currentValueWaveForm[index] != 93) {
            // [ e ]
            _dataWaveForm[indexDataArray] = _currentValueWaveForm[index];
            dataFreq = _currentValueWaveForm[index];
          }
          else if(_currentValueWaveForm[index] == 93){
            blueData = BluetoothData.checksum;
          }
          index++;
        break;

        case BluetoothData.checksum:
          
          crc32 = 0xFFFFFFFF - crc32;
          checksumString = crc32.toRadixString(16);
          blueData = BluetoothData.etx;
          for(int i = 0; i < 4; i++){
            if(checksumString[0].toUpperCase().codeUnitAt(0) != _currentValueWaveForm[index]){
              blueData = BluetoothData.done;
              break;
            }
            index++;
          }
        break;

        case BluetoothData.etx:
          if(_currentValueWaveForm[index] == 3){
            if(commandData == 71){   //G
              DeviceBloodPressure.getInstance().setValueWaveForm(_dataWaveForm);
              _dataWaveForm.clear();
            }
            else if (commandData == 72){  //H
              DeviceBloodPressure.getInstance().setFrequencyEachValue(dataFreq);
              
              setState(() {
                minBPValue = DeviceBloodPressure.getInstance().getMinValueFromValueWaveForm()-10;
                maxBPValue = DeviceBloodPressure.getInstance().getMaxValueFromValueWaveForm()+10;
                arrayBP = DeviceBloodPressure.getInstance().getValueWaveForm();
                freq = DeviceBloodPressure.getInstance().getFrequencyEachValue();
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

  Future<void> saveBloodPressureWaveForm() async{
    /*Le o json, adiciona os itens e salva novamente */
    await DeviceBloodPressure.getInstance().getListJsonFromPath();
    DeviceBloodPressure.getInstance().addNewItemsListJson();
    await DeviceBloodPressure.getInstance().saveListJsonToPath();
  }

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
          title: Text(DeviceBloodPressure.getInstance().getDeviceBloodPressure().localName.toUpperCase()),
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
                  child: 
                    ChartWaveFormScreen(
                      minBPValue: minBPValue,
                      maxBPValue: maxBPValue,
                      arrayBP: arrayBP,
                      freq: freq,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async{
                    await saveBloodPressureWaveForm();
                  },
                  child: const Text("SALVAR"),
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
                  child: Text(
                    "ESPERANDO PELOS VALORES",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color:  Color.fromARGB(255, 73, 2, 111),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              CircularProgressIndicator(),
            ]
          ),
        ),
      ),
    );
  }
}