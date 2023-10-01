import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';

class DeviceBloodPressure{
  static DeviceBloodPressure? _deviceBPClass;
  BluetoothDevice? deviceBloodPressure;
  bool isDeviceBloodPressureSetted = false;
  List<BluetoothCharacteristic> serviceDevices = [];
  String valueDefaultSBP = '0';
  String valueDefaultDBP = '0';
  List<int> valueWaveForm = [];
  int frequencyEachValue = 0;
  List<Map<String, dynamic>> listJson = [];

  DeviceBloodPressure();

    static DeviceBloodPressure getInstance() {
    _deviceBPClass ??= DeviceBloodPressure();
    return _deviceBPClass!;
  }

  BluetoothDevice getDeviceBloodPressure(){
    return deviceBloodPressure!;
  }

  Future<void> setDeviceBloodPressure(BluetoothDevice blueDevice) async{
     deviceBloodPressure = blueDevice;
     isDeviceBloodPressureSetted = true;
  }

  Future<void> setMTU() async{
     await deviceBloodPressure!.requestMtu(50);
  }

  List<BluetoothCharacteristic> getServiceDevices(){
    return serviceDevices;
  }

  void setServicesDevices(){
    for(var service in deviceBloodPressure!.servicesList!){
      for(var caracter in service.characteristics){
        print(caracter.characteristicUuid);
      }
      serviceDevices = service.characteristics.where(
        (element) {
          if(element.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
            element.write([0x42,0x4c,0x4f,0x4f,0x44], withoutResponse: element.properties.writeWithoutResponse);
            return true;
          }
          else if(element.characteristicUuid.toString() == "86d3ac32-8756-11e7-bb31-be2e44b06b34"){
            element.setNotifyValue(element.isNotifying == false);
            return true;
          }
          return false;
        }
        ).toList();
    }
  }

  void setValueWaveForm(List<int> newValues){
    valueWaveForm.addAll(newValues);
  }

  List<int> getValueWaveForm(){
    return valueWaveForm;
  }

  int getMinValueFromValueWaveForm(){
    return valueWaveForm.reduce((value, element) => min(value, element));
  }

  int getMaxValueFromValueWaveForm(){
    return valueWaveForm.reduce((value, element) => max(value, element));
  }

  void setFrequencyEachValue(int value){
    frequencyEachValue = value;
  }

  int getFrequencyEachValue(){
    return frequencyEachValue;
  }

  String getValueSBP(){
    return valueDefaultSBP;
  }

  void setValueSBP(String value){
    valueDefaultSBP = value;
  }

  String getValueDBP(){
    return valueDefaultDBP;
  }

  void setValueDBP(String value){
    valueDefaultDBP = value;
  }

  Future<void> getListJsonFromPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dataBP.json');

    try {
      // Lê o conteúdo do arquivo JSON
      final jsonString = await file.readAsString();
      // Converte a string JSON de volta para um mapa
      listJson = jsonDecode(jsonString);
    } 
    catch (e) {
      // Trata qualquer erro que possa ocorrer durante a operação de leitura
      print('Erro ao ler JSON: $e');
    }
  }

  void addNewItemsListJson(){
    DateTime dataAtual = DateTime.now();
    Map<String, dynamic> newItem = {
      'data': '${dataAtual.day}/${dataAtual.month}/${dataAtual.year}',
      'valorDBP': valueDefaultDBP,
      'valorSBP': valueDefaultSBP,
      'ondaDePressao': getValueWaveForm(),
      'frequencia': frequencyEachValue,
    };
    listJson.add(newItem);
  }

  Future<void> saveListJsonToPath()async{
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dataBP.json');
    if (await file.exists()) {
        // Converta a lista atualizada em uma string JSON
        String listaJsonString = jsonEncode(listJson);
        // Salve a lista atualizada no arquivo
        await file.writeAsString(listaJsonString);
        print('Item adicionado e arquivo atualizado com sucesso.');
      } else {
        print('O arquivo JSON não existe. Crie-o primeiro.');
      }
  }
}
