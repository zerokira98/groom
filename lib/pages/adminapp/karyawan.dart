import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';
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
                                selectedIdx =
                                    selectedIdx == index ? null : index;
                                passcon.text =
                                    snapshot.data![index].password ?? '';
                              });
                            },
                            trailing: IconButton(
                                onPressed: () {
                                  RepositoryProvider.of<KaryawanRepository>(
                                          context)
                                      .update(snapshot.data![index].copyWith(
                                          aktif: !snapshot.data![index].aktif))
                                      .then((value) => Navigator.pop(context));
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
            Flexible(
              flex: 3,
              child: Card(
                child: Column(
                  children: [
                    Row(children: [
                      Text(selectedIdx != null
                          ? 'Karyawan Input'
                          : 'Tambah Karyawan')
                    ]),
                    if (selectedIdx != null) const Text('setPassword'),
                    if (selectedIdx != null)
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
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
                    if (selectedIdx != null)
                      ElevatedButton(
                          onPressed: () async {
                            if (nama != null) {
                              var a = await RepositoryProvider.of<
                                      KaryawanRepository>(context)
                                  .update(nama!
                                      .copyWith(password: () => passcon.text))
                                  .then((value) {
                                setState(() {});
                                Flushbar(
                                  message: 'Success',
                                  duration: const Duration(seconds: 2),
                                  animationDuration: Durations.long1,
                                ).show(context);
                              });
                            }
                          },
                          child: const Text('Submit')),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
