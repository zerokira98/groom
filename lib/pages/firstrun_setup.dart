import 'package:flutter/material.dart';
import 'package:groom/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstRun extends StatelessWidget {
  const FirstRun({super.key});
  Future _setFirstTime() async {
    var a = await SharedPreferences.getInstance();
    return await a.setBool('firstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              // List karyawanfirst = [
              //   const KaryawanData(
              //       id: 0,
              //       namaKaryawan: 'Mazzany',
              //       aktif: true,
              //       password: '123456'),
              //   const KaryawanData(
              //       id: 1,
              //       namaKaryawan: 'Rudy',
              //       aktif: true,
              //       password: '123456'),
              //   const KaryawanData(
              //       id: 2,
              //       namaKaryawan: 'Alfin',
              //       aktif: true,
              //       password: '123456'),
              //   const KaryawanData(
              //       id: 3,
              //       namaKaryawan: 'Febri',
              //       aktif: true,
              //       password: '123456'),
              //   const KaryawanData(
              //       id: 4,
              //       namaKaryawan: 'Indra',
              //       aktif: true,
              //       password: '123456'),
              //   const KaryawanData(
              //       id: 5,
              //       namaKaryawan: 'Yudha',
              //       aktif: true,
              //       password: '123456'),
              // ];
              // for (var e in karyawanfirst) {
              //   await RepositoryProvider.of<KaryawanRepository>(context)
              //       .addKaryawan(e);
              // }
              await _setFirstTime().then((value) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApp(),
                    ),
                    (route) => false);
              });
            },
            child: const Text('Let Me In!')),
      ),
    );
  }
}
