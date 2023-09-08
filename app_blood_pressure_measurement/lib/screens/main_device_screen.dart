import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting;
  GlobalKey<ScaffoldMessengerState> snackBarKeyA;
  GlobalKey<ScaffoldMessengerState> snackBarKeyB;
  GlobalKey<ScaffoldMessengerState> snackBarKeyC;
  List<BluetoothCharacteristic>? serviceTest; 
  final String _selectedMenuItem = 'None';
  bool _isTextFieldVisible = false;
  final TextEditingController _controllerDBP = TextEditingController();
  final TextEditingController _controllerSBP = TextEditingController();
  //final FocusNode _focusNode = FocusNode();
  bool _calibrateStarted = false;
  bool _disconnected = true;

  MainDeviceScreen(
    {
      super.key, 
    required this.device, 
    required this.isConnectingOrDisconnecting, 
    required this.snackBarKeyA,
    required this.snackBarKeyB,
    required this.snackBarKeyC,
    }
  );

  @override
  State<MainDeviceScreen> createState() => _MainDeviceScreenState();
}

class _MainDeviceScreenState extends State<MainDeviceScreen> {
  String valueDefaultBPS = '0';
  String valueDefaultBPD = '0';

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
      _getValueBP();
    });
  }

  _asyncMethod() async {
    try {
      await connectToDevice(context);
      setState(() {
        widget._disconnected = false;      
      });
      // await widget.device.discoverServices();
      // getListOfCharacteristic();
      // final snackBar = snackBarGoodDeviceScreen("Discover Services: Success");
      // widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
      // widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      // print("Success");
      } catch (e) {
      // final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Discover Services Error:", e));
      // widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
      // widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      print("Fail");
    }
  }
  
    Future<void> _getValueBP() async{
      final prefs = await SharedPreferences.getInstance();
      valueDefaultBPS = prefs.getString('PBS') ?? '0';
      valueDefaultBPD = prefs.getString('PBD') ?? '0';
    }
  
    Future<void> _changeValueBPS(String value) async{
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('PBS', value);
    }
  
    Future<void> _changeValueBPD(String value) async{
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('PBD', value);
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

    List<int> separateNumberToList(int number) {
    // Convert the number to a string
    String numberAsString = number.toString();
    
    // Use the split method to get a list of individual digit characters
    List<String> digitCharacters = numberAsString.split('');
    
    // Convert the list of digit characters back to integers
    List<int> digitList = digitCharacters.map((char) => int.parse(char)).toList();
    
    return digitList;
  }

  setBloodPressureArray(List<int> listOfDBP, List<int> listOfSBP){
    List<int> bloodPressureArray = [];
    //List<int> checkSumArray = [];
    int checkSum = 0;//, decimalNumber = 255;
    String checkSumHex;

    bloodPressureArray.add(0x02); //STX
    bloodPressureArray.add(0x70); //p
    checkSum ^= 0x70;
    bloodPressureArray.add(0x62); //b
    checkSum ^= 0x62;
    bloodPressureArray.add(0x42); //B
    checkSum ^= 0x42;
    bloodPressureArray.add(0x5B); //[
    checkSum ^= 0x5B;

    for(int index = 0; index < listOfDBP.length; index++){
      bloodPressureArray.add(listOfDBP[index] + 0x30);
      checkSum ^= listOfDBP[index] + 0x30;
    }
    
    bloodPressureArray.add(0x2C); //,
    checkSum ^= 0x2C;

    for(int index = 0; index < listOfSBP.length; index++){
      bloodPressureArray.add(listOfSBP[index] + 0x30);
      checkSum ^= listOfSBP[index] + 0x30;
    }

    bloodPressureArray.add(0x5D); //]
    checkSum ^= 0x5D;
    print(" CHECKSUM $checkSum");

    checkSumHex = checkSum.toRadixString(16);
    //checkSumArray = separateNumberToList(checkSum);
    for(int index = 0; index < checkSumHex.length; index++){
      //if(checkSumHex[index])
      bloodPressureArray.add(checkSumHex[index].toUpperCase().codeUnitAt(0));
    }

    //print('int: 0x${checkSumHex[1].toUpperCase().codeUnitAt(0)}');
    
    bloodPressureArray.add(0x03); //ETX

    return bloodPressureArray;
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
      widget.isConnectingOrDisconnecting[widget.device.remoteId] ??= ValueNotifier(true);
      widget.isConnectingOrDisconnecting[widget.device.remoteId]!.value = true;
      try {
        await widget.device.disconnect();
        final snackBar = snackBarGoodDeviceScreen("Disconnect: Success");
        widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
        widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      } catch (e) {
        final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Disconnect Error:", e));
        widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
        widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      }
      widget.isConnectingOrDisconnecting[widget.device.remoteId] ??= ValueNotifier(false);
      widget.isConnectingOrDisconnecting[widget.device.remoteId]!.value = false;
  }

  Future<void> connectToDevice(BuildContext context)async{
    widget.isConnectingOrDisconnecting[widget.device.remoteId] ??= ValueNotifier(true);
    widget.isConnectingOrDisconnecting[widget.device.remoteId]!.value = true;
    try {
      await widget.device.connect(timeout: const Duration(seconds: 35));
      final snackBar = snackBarGoodDeviceScreen("Connect: Success");
      widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
      widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
    } catch (e) {
      final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Connect Error:", e));
      widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
      widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      }
    widget.isConnectingOrDisconnecting[widget.device.remoteId] ??= ValueNotifier(false);
    widget.isConnectingOrDisconnecting[widget.device.remoteId]!.value = false;

    try {
      await widget.device.discoverServices();
      getListOfCharacteristic();
      final snackBar = snackBarGoodDeviceScreen("Discover Services: Success");
      widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
      widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      print("Success");
    } catch (e) {
      final snackBar = snackBarFailDeviceScreen(prettyExceptionDeviceScreen("Discover Services Error:", e));
      widget.snackBarKeyC.currentState?.removeCurrentSnackBar();
      widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
      print("Fail");
    }
  }

  void pressedStart(BuildContext context){
    List<int> sendStartArray = [0x02, 0x70, 0x62, 0x41, 0x35, 0x33, 0x03];
    for(BluetoothCharacteristic c in widget.serviceTest!){
      if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
        c.write(sendStartArray, withoutResponse: c.properties.writeWithoutResponse);
      }
    }
  }

  void calibrateSensor(BuildContext context){
    //start calibrate
    if(!widget._calibrateStarted){
      List<int> sendCalibrateArray = [0x02, 0x70, 0x62, 0x43, 0x35, 0x31, 0x03];
      for(BluetoothCharacteristic c in widget.serviceTest!){
        if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
          c.write(sendCalibrateArray, withoutResponse: c.properties.writeWithoutResponse);
        }
      }
    }
    
    //send calibrate
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(25, 25, 0, 0),
      items: <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: '60',
                child: Text('60'),
              ),
              const PopupMenuItem<String>(
                value: '200',
                child: Text('200'),
              ),
      ]
    ).then((value){
        if(value != null){
          //_handleMenuItemSelection = value;
          List<int> sendCalibrateArray;
          if(value == '60'){
            sendCalibrateArray = [0x02, 0x70, 0x62, 0x44, 0x35, 0x36, 0x03];
            setState(() {
              widget._calibrateStarted = true;              
            });
          }
          else{
            sendCalibrateArray = [0x02, 0x70, 0x62, 0x45, 0x35, 0x37, 0x03];
            setState(() {
              widget._calibrateStarted = false;              
            });
          }
          for(BluetoothCharacteristic c in widget.serviceTest!){
            if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
              c.write(sendCalibrateArray, withoutResponse: c.properties.writeWithoutResponse);
            }
          }
        }
      }     
    );
  }

  Future<void> SendBPData(BuildContext context)async{
    List<int> listOfDBP = [];
    List<int> listOfSBP = [];
    List<int> sendBloodpressureArray = [];
    if(widget._controllerDBP.text != '') {
      listOfDBP =separateNumberToList(int.parse(widget._controllerDBP.text));
      await _changeValueBPD(widget._controllerDBP.text);
    }
    else{
      listOfDBP =separateNumberToList(int.parse(valueDefaultBPD));
      print(listOfDBP);
    }
    if(widget._controllerSBP.text != '') {
      listOfSBP =separateNumberToList(int.parse(widget._controllerSBP.text));
      await _changeValueBPS(widget._controllerSBP.text);
    }
    else{
      listOfSBP =separateNumberToList(int.parse(valueDefaultBPS));
      print(listOfSBP);
    }

    sendBloodpressureArray = setBloodPressureArray(listOfDBP, listOfSBP);

    for(BluetoothCharacteristic c in widget.serviceTest!){
      if(c.characteristicUuid.toString() == "32550a96-8bf4-11e7-bb31-be2e44b06b34"){
        c.write(sendBloodpressureArray, withoutResponse: c.properties.writeWithoutResponse);
      }
    }
  }

  bool isDisconected(BuildContext context){
    return widget._disconnected;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: widget.snackBarKeyA,
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
                      setState(() {
                        widget._disconnected = true;                    
                      });
                      await desconnectToDevice(context);
                    };
                    text = 'DESCONECTAR';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      setState(() {
                        widget._disconnected = false;                    
                      });
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
                  valueListenable: widget.isConnectingOrDisconnecting[widget.device.remoteId]!,
                  builder: (context,value,child){
                    widget.isConnectingOrDisconnecting[widget.device.remoteId] ??= ValueNotifier(false);
                    if (widget.isConnectingOrDisconnecting[widget.device.remoteId]!.value == true){
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
        body: isDisconected(context) ?
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 0, 230, 215), Colors.blue], // Define your gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'APARELHO DESCONECTADO',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 24.0, // Font size
                  fontWeight: FontWeight.bold, // Text weight
                  fontFamily: 'Pacifico', // Custom font (ensure to load the font)
                ),
              ),
            ),
          ),
        )
        : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () => pressedStart(context),
                child: const Text("Começar"),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: (() {
                  setState(() {
                    if(widget._isTextFieldVisible){
                      widget._isTextFieldVisible = false;                  
                    }
                    else {
                      widget._isTextFieldVisible = true;
                    } 
                  });
                }),
                child: const Text("Valores de pressão"),
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
              if(widget._isTextFieldVisible)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: widget._controllerDBP,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: InputDecoration(
                          labelText: valueDefaultBPD == '0' ? 'Valor da Pressão Arterial Distólica' : 'Valor da Pressão Distólica é $valueDefaultBPD',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: widget._controllerSBP,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: InputDecoration(
                          labelText: valueDefaultBPS == '0' ? 'Valor da Pressão Arterial Sistólica' : 'Valor da Pressão Sistólica é $valueDefaultBPS',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],  
                ),
            ],
          ),
        ),
      ),
    );
  }
}

