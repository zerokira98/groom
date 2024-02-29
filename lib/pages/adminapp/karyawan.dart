import 'package:another_flushbar/flushbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/model/model.dart';

class KaryawanConfig extends StatefulWidget {
  const KaryawanConfig({super.key});

  @override
  State<KaryawanConfig> createState() => _KaryawanConfigState();
}

class _KaryawanConfigState extends State<KaryawanConfig> {
  KaryawanData? nama;
  int? selectedIdx;
  bool visible = false;
  TextEditingController passcon = TextEditingController();
  TextEditingController namaController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  Widget options() {
    return Card(
      child: Form(
        key: formkey,
        child: Column(
          children: [
            Row(children: [
              Text(selectedIdx != null ? 'Karyawan Input' : 'Tambah Karyawan')
            ]),
            if (selectedIdx != null) const Text('setPassword'),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.isEmpty) return 'cant be empty';
                    if (value.length < 4) return 'at least 4';
                    return null;
                  },
                  enabled: (selectedIdx == null),
                  controller: namaController,
                  decoration: const InputDecoration(
                    label: Text('Nama Karyawan'),
                  ),
                  obscureText: visible,
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.isEmpty) return 'cant be empty';
                    if (value.length < 4) return 'at least 4';
                    return null;
                  },
                  controller: passcon,
                  decoration: InputDecoration(
                      label: const Text('Password'),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              visible = !visible;
                            });
                          },
                          icon: Icon(visible
                              ? Icons.visibility
                              : Icons.visibility_off))),
                  obscureText: visible,
                ))
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  if (selectedIdx != null && nama != null) {
                    var a = await RepositoryProvider.of<KaryawanRepository>(
                            context)
                        .update(nama!.copyWith(password: () => passcon.text))
                        .then((value) {
                      setState(() {});
                      Flushbar(
                        message: 'Success',
                        duration: const Duration(seconds: 2),
                        animationDuration: Durations.long1,
                      ).show(context);
                    });
                  } else {
                    if (formkey.currentState!.validate()) {
                      var a = await RepositoryProvider.of<KaryawanRepository>(
                              context)
                          .addKaryawan(KaryawanData(
                              namaKaryawan: namaController.text,
                              password: passcon.text,
                              aktif: true))
                          .then((value) {
                        if (value == 1) {
                          Flushbar(
                            message: 'Success',
                            duration: const Duration(seconds: 2),
                            animationDuration: Durations.long1,
                          ).show(context);
                          setState(() {
                            nama = null;
                            namaController.text = nama?.namaKaryawan ?? '';
                            selectedIdx = null;
                            passcon.text = nama?.password ?? '';
                          });
                        }
                      });
                    }
                  }
                },
                child: const Text('Submit')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Atur Karyawan'),
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: RepositoryProvider.of<KaryawanRepository>(context)
                  .getAllKaryawan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SizedBox();
                  } else {
                    return Expanded(
                      flex: 4,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ListTile(
                            selected: selectedIdx == index,
                            onTap: () {
                              setState(() {
                                nama = selectedIdx == index
                                    ? null
                                    : snapshot.data![index];
                                namaController.text = nama?.namaKaryawan ?? '';
                                selectedIdx =
                                    selectedIdx == index ? null : index;
                                passcon.text = nama?.password ?? '';
                              });
                            },
                            trailing: IconButton(
                                onPressed: () async {
                                  final connectivityResult =
                                      await (Connectivity()
                                          .checkConnectivity());
                                  if (connectivityResult !=
                                      ConnectivityResult.none) {
                                    RepositoryProvider.of<KaryawanRepository>(
                                            context)
                                        .update(snapshot.data![index].copyWith(
                                            aktif:
                                                !snapshot.data![index].aktif))
                                        .then(
                                            (value) => Navigator.pop(context));
                                  }
                                },
                                icon: const Icon(Icons.power_settings_new)),
                            selectedTileColor: Colors.black38,
                            title: Text(snapshot.data![index].namaKaryawan),
                            subtitle: Text(snapshot.data![index].aktif
                                ? 'aktif'
                                : 'nonaktif'),
                          );
                        },
                        itemCount: snapshot.data!.length,
                      ),
                    );
                  }
                }
                return const CircularProgressIndicator();
              },
            ),
            options()
          ],
        ));
  }
}
