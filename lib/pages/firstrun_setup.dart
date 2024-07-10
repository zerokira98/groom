import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groom/etc/globalvar.dart';
import 'package:groom/etc/lockscreen_keylock.dart';
import 'package:groom/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstRun extends StatelessWidget {
  const FirstRun({super.key});
  Future _setFirstTime() async {
    var a = await SharedPreferences.getInstance();
    await a.setString('adminpass', '12340');
    return await a.setBool('firstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome!, admin pass is reset'),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  _setFirstTime().then((value) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          KeyLock(tendigits: adminpass, title: 'Software pass'),
                    ).then((value) {
                      if (value != null && value) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const MyApp(),
                            ),
                            (route) => false);
                      }
                    });
                  });
                },
                child: const Text('Let Me In!')),
          ),
        ],
      ),
    );
  }
}
