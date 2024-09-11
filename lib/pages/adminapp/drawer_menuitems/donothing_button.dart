import 'package:flutter/material.dart';

class DoNothingButton extends StatelessWidget {
  const DoNothingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // RepositoryProvider.of<MidApi>(context).getFlutterTest();
      },
      child: const Text('Do Nothing Button'),
    );
  }
}
