import 'package:another_flushbar/flushbar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groom/etc/extension.dart' as x;
import 'package:groom/model/model.dart';

class PrintWidget extends StatefulWidget {
  final StrukMdl theData;
  const PrintWidget({super.key, required this.theData});

  @override
  State<PrintWidget> createState() => _PrintWidgetState();
}

class _PrintWidgetState extends State<PrintWidget> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];

  BluetoothDevice? _device;

  bool _connected = false;
  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint('telo platform exception');
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            debugPrint("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            debugPrint("bluetooth device state: error");
          });
          break;
        default:
          debugPrint(state.toString());
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void connect(BuildContext context) {
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) {
        debugPrint('here$isConnected');
        // if (isConnected == false) {
        bluetooth.connect(_device!).catchError((error) {
          debugPrint('here$error');
          setState(() => _connected = false);
        }).then((value) => setState(() => _connected = true));
        // }
      });
    } else {
      Flushbar(
        message: 'No device selected.',
        duration: const Duration(seconds: 2),
        animationDuration: Durations.long1,
      ).show(context);
      // show(context, );
    }
  }

  void disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devices) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name ?? ""),
        ));
      }
    }
    return items;
  }

  void printThermal(StrukMdl theData) {
    var blue = BlueThermalPrinter.instance;
    try {
      blue.isConnected.then((value) {
        if (value == null || value == false) return;
        var sumtotal = 0;

        blue.printCustom('Groom', x.Size.extraLarge.val, x.Align.center.val);
        blue.printCustom(
            'Barbershop', x.Size.extraLarge.val, x.Align.center.val);
        blue.printCustom(
            'Jl.Gajahmada no.xx', x.Size.medium.val, x.Align.center.val);
        blue.printNewLine();
        blue.printCustom(
            theData.id ?? 'null', x.Size.medium.val, x.Align.right.val);
        blue.printCustom(theData.tanggal.formatLengkap(), x.Size.medium.val,
            x.Align.right.val);
        blue.printCustom(
            theData.tanggal.clockOnly(), x.Size.medium.val, x.Align.right.val);
        blue.printCustom('Karyawan: ${theData.namaKaryawan}', x.Size.medium.val,
            x.Align.right.val);
        blue.printNewLine();
        for (var i = 0; i < theData.itemCards.length; i++) {
          sumtotal +=
              theData.itemCards[i].pcsBarang * theData.itemCards[i].price;
          var col1 = theData.itemCards[i].pcsBarang.toString();
          var col2 =
              (theData.itemCards[i].price * theData.itemCards[i].pcsBarang)
                  .numberFormat(currency: true);

          var col0 =
              "${cardType[theData.itemCards[i].type].toString().toUpperCase()} :  ${theData.itemCards[i].namaBarang.toUpperCase()}";
          blue.printLeftRight(col0, col1, x.Size.bold.val);
          blue.printLeftRight('', col2, x.Size.bold.val);
        }
        blue.printNewLine();
        blue.printLeftRight("TOTAL :", sumtotal.numberFormat(currency: true),
            x.Size.boldLarge.val);

        blue.printNewLine();
        blue.printCustom("Thank you for using our service.",
            x.Size.boldLarge.val, x.Align.center.val);
        blue.printNewLine();
        blue.printQRcode("instagram.com/groom_barbershop_pare", 200, 200,
            x.Align.center.val);
        blue.paperCut();
        return null;
      }).catchError((e) {
        debugPrint(e.toString());
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Device:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            child: DropdownButton(
              items: getDeviceItems(),
              onChanged: (BluetoothDevice? value) =>
                  setState(() => _device = value),
              value: _device,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: () {
              initPlatformState();
            },
            child: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _connected ? Colors.red : Colors.green),
            onPressed: () => _connected ? disconnect() : connect(context),
            child: Text(
              _connected ? 'Disconnect' : 'Connect',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      ElevatedButton(
          onPressed: () {
            printThermal(widget.theData);
            // generatePDF(false, theData);
          },
          child: const Text('Print bluetooth')),
    ]);
  }
}
