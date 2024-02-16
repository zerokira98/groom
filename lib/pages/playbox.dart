import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class PlayBox extends StatelessWidget {
  const PlayBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: TextButton(
              onPressed: () async {
                ///==-=-=-
                var availability = await FlutterNfcKit.nfcAvailability;
                if (availability != NFCAvailability.available) {
                  print('oh no');
                  // oh-no
                } else {
                  print('oh yes');
                }

                ///
// timeout only works on Android, while the latter two messages are only for iOS
                var tag = await FlutterNfcKit.poll(
                    timeout: const Duration(seconds: 15),
                    iosMultipleTagMessage: "Multiple tags found!",
                    iosAlertMessage: "Scan your tag");
                print(tag.toJson());
              },
              child: const Text('Lets play!'))),
    );
  }
}
