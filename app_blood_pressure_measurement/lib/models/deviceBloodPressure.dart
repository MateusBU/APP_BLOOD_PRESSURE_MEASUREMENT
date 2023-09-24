import 'dart:io';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceBloodPressure{
  static DeviceBloodPressure? _deviceBPClass;
  BluetoothDevice? deviceBloodPressure;
  bool isDeviceBloodPressureSetted = false;
  List<BluetoothCharacteristic> serviceDevices = [];
  String valueDefaultSBP = '0';
  String valueDefaultDBP = '0';
  List<int> valueWaveForm = [];
  int frequencyEachValue = 0;

  DeviceBloodPressure();

    static DeviceBloodPressure getInstance() {
    _deviceBPClass ??= DeviceBloodPressure();
    return _deviceBPClass!;
  }

  BluetoothDevice getDeviceBloodPressure(){
    return deviceBloodPressure!;
  }

  void setDeviceBloodPressure(BluetoothDevice blueDevice){
     deviceBloodPressure = blueDevice;
     isDeviceBloodPressureSetted = true;
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
}
