import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MainDeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  final Map<DeviceIdentifier, ValueNotifier<bool>> is_connecting_or_disconnecting;
  GlobalKey<ScaffoldMessengerState> snack_bar_key_A;
  GlobalKey<ScaffoldMessengerState> snack_bar_key_B;
  GlobalKey<ScaffoldMessengerState> snack_bar_key_C;
  List<BluetoothCharacteristic>? serviceTest; 

  MainDeviceScreen(
    {
      super.key, 
    required this.device, 
    required this.is_connecting_or_disconnecting, 
    required this.snack_bar_key_A,
    required this.snack_bar_key_B,
    required this.snack_bar_key_C,
    }
  );

  @override
  State<MainDeviceScreen> createState() => _MainDeviceScreenState();
}

class _MainDeviceScreenState extends State<MainDeviceScreen> {

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    try {
      await connectToDevice(context);
      await widget.device.discoverServices();
      getListOfCharacteristic();
      final snackBar = snackBarGoodDeviceScreen("Discover Services: Success");
      widget.snack_bar_key_C.currentState?.removeCurrentSnackBar();
      widget.snack_bar_key_C.currentState?.showSnackBar(snackBar);
      print("Success");
      } catch (e) {
      final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Discover Services Error:", e));
      widget.snack_bar_key_C.currentState?.removeCurrentSnackBar();
      widget.snack_bar_key_C.currentState?.showSnackBar(snackBar);
      print("Fail");
    }
  }

  SnackBar snackBarGoodDeviceScreen(String message) {
    return SnackBar(content: Text(message), backgroundColor: Colors.blue);
  }

  SnackBar snackBarFailDeviceScreen(String message) {
    return SnackBar(content: Text(message), backgroundColor: Colors.red);
  }

  String prettyExceptionDeviceScreen(String prefix, dynamic e) {
    if (e is FlutterBluePlusException) {
      return "$prefix ${e.description}";
    } else if (e is PlatformException) {
      return "$prefix ${e.message}";
    }
    return prefix + e.toString();
  }

  void getListOfCharacteristic(){
    for(var s in widget.device.servicesList!){
      for(var c in s.characteristics){
        print(c.characteristicUuid);

      }
      widget.serviceTest = s.characteristics.where(
        (element) {
          if(element.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
            element.write([0x42,0x4c,0x4f,0x4f,0x44], withoutResponse: element.properties.writeWithoutResponse);
            return true;
          }
          else if(element.characteristicUuid.toString() == "86d3ac32-8756-11e7-bb31-be2e44b06b34"){
            //element.setNotifyValue(element.isNotifying == false);
            return true;
          }
          return false;
        }
        ).toList();
    }
      
  }

  Future<void> desconnectToDevice(BuildContext context)async{
      widget.is_connecting_or_disconnecting[widget.device.remoteId] ??= ValueNotifier(true);
      widget.is_connecting_or_disconnecting[widget.device.remoteId]!.value = true;
      try {
        await widget.device.disconnect();
        final snackBar = snackBarGoodDeviceScreen("Disconnect: Success");
        widget.snack_bar_key_C.currentState?.removeCurrentSnackBar();
        widget.snack_bar_key_C.currentState?.showSnackBar(snackBar);
      } catch (e) {
        final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Disconnect Error:", e));
        widget.snack_bar_key_C.currentState?.removeCurrentSnackBar();
        widget.snack_bar_key_C.currentState?.showSnackBar(snackBar);
      }
      widget.is_connecting_or_disconnecting[widget.device.remoteId] ??= ValueNotifier(false);
      widget.is_connecting_or_disconnecting[widget.device.remoteId]!.value = false;
  }

  Future<void> connectToDevice(BuildContext context)async{
    widget.is_connecting_or_disconnecting[widget.device.remoteId] ??= ValueNotifier(true);
    widget.is_connecting_or_disconnecting[widget.device.remoteId]!.value = true;
    try {
      await widget.device.connect(timeout: const Duration(seconds: 35));
      final snackBar = snackBarGoodDeviceScreen("Connect: Success");
      widget.snack_bar_key_C.currentState?.removeCurrentSnackBar();
      widget.snack_bar_key_C.currentState?.showSnackBar(snackBar);
    } catch (e) {
      final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Connect Error:", e));
      widget.snack_bar_key_C.currentState?.removeCurrentSnackBar();
      widget.snack_bar_key_C.currentState?.showSnackBar(snackBar);
      }
    widget.is_connecting_or_disconnecting[widget.device.remoteId] ??= ValueNotifier(false);
    widget.is_connecting_or_disconnecting[widget.device.remoteId]!.value = false;
  }

  void pressedStart(BuildContext context){
    for(BluetoothCharacteristic c in widget.serviceTest!){
      if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
        c.write([0x53,0x54,0x41,0x52,0x54], withoutResponse: c.properties.writeWithoutResponse);
      }
    }
  }

  void calibrateSensor(BuildContext context){
    for(BluetoothCharacteristic c in widget.serviceTest!){
      if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
        c.write([0x43,0x41,0x4c,0x49,0x42,0x52,0x41,0x54,0x45], withoutResponse: c.properties.writeWithoutResponse);
      }
    }
  }

  void SendBPData(BuildContext context){
    for(BluetoothCharacteristic c in widget.serviceTest!){
      if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
        c.write([0x42,0x50], withoutResponse: c.properties.writeWithoutResponse);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: widget.snack_bar_key_A,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.device.localName.toUpperCase()),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: widget.device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: ((c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch(snapshot.data){
                  case BluetoothConnectionState.connected:
                    onPressed = () async {
                      await desconnectToDevice(context);
                    };
                    text = 'DESCONECTAR';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      await connectToDevice(context);
                    };
                    text = 'CONECTAR';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().split(".").last.toUpperCase();
                    break;
                }
                return ValueListenableBuilder<bool>(
                  valueListenable: widget.is_connecting_or_disconnecting[widget.device.remoteId]!,
                  builder: (context,value,child){
                    widget.is_connecting_or_disconnecting[widget.device.remoteId] ??= ValueNotifier(false);
                    if (widget.is_connecting_or_disconnecting[widget.device.remoteId]!.value == true){
                        // Show spinner when connecting or disconnecting
                      return const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black12,
                            color: Colors.black26,
                          ),
                        ),
                      );
                    } 
                    else {
                      return TextButton(
                        onPressed: onPressed,
                        child: Text(
                          text,
                          style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.white),
                        )
                      );
                    }
                  }
                );
              }),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () => pressedStart(context),
                child: const Text("Start"),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => SendBPData(context),
                    child: const Text("Enviar Dados"),
                  ),
                  ElevatedButton(
                    onPressed: () => calibrateSensor(context),
                    child: const Text("Calibrar"),
                  ),
                ],
              ),
              const Text("Characteristic"),
            ],
          ),
        ),
      ),
    );
  }
}

