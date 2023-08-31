import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MainDeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  final Map<DeviceIdentifier, ValueNotifier<bool>> is_connecting_or_disconnecting;
  GlobalKey<ScaffoldMessengerState> snack_bar_key_A;
  GlobalKey<ScaffoldMessengerState> snack_bar_key_B;
  GlobalKey<ScaffoldMessengerState> snack_bar_key_C;

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
                      // is_connecting_or_disconnecting[device.remoteId] ??= ValueNotifier(true);
                      // is_connecting_or_disconnecting[device.remoteId]!.value = true;
                      // try {
                      //   await device.disconnect();
                      //   final snackBar = snackBarGoodDeviceScreen("Disconnect: Success");
                      //   snack_bar_key_C.currentState?.removeCurrentSnackBar();
                      //   snack_bar_key_C.currentState?.showSnackBar(snackBar);
                      // } catch (e) {
                      //   final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Disconnect Error:", e));
                      //   snack_bar_key_C.currentState?.removeCurrentSnackBar();
                      //   snack_bar_key_C.currentState?.showSnackBar(snackBar);
                      // }
                      // is_connecting_or_disconnecting[device.remoteId] ??= ValueNotifier(false);
                      // is_connecting_or_disconnecting[device.remoteId]!.value = false;
                    };
                    text = 'DESCONECTAR';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      await connectToDevice(context);
                      // is_connecting_or_disconnecting[device.remoteId] ??= ValueNotifier(true);
                      // is_connecting_or_disconnecting[device.remoteId]!.value = true;
                      // try {
                      //   await device.connect(timeout: const Duration(seconds: 35));
                      //   final snackBar = snackBarGoodDeviceScreen("Connect: Success");
                      //   snack_bar_key_C.currentState?.removeCurrentSnackBar();
                      //   snack_bar_key_C.currentState?.showSnackBar(snackBar);
                      // } catch (e) {
                      //   final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Connect Error:", e));
                      //   snack_bar_key_C.currentState?.removeCurrentSnackBar();
                      //   snack_bar_key_C.currentState?.showSnackBar(snackBar);
                      // }
                      // is_connecting_or_disconnecting[device.remoteId] ??= ValueNotifier(false);
                      // is_connecting_or_disconnecting[device.remoteId]!.value = false;
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
      ),
    );
  }
}

