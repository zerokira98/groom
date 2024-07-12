import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/midapi.dart';

class DoNothingButton extends StatelessWidget {
  const DoNothingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        RepositoryProvider.of<MidApi>(context).getFlutterTest();
      },
      child: const Text('Do Nothing Button'),
    );
  }
}
