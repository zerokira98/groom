import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/drawer.dart';
import 'package:groom/etc/extension.dart';

import 'package:groom/itemcard.dart';
import 'package:groom/pages/riwayat_pemasukan.dart';

class Home extends StatelessWidget {
  Home({super.key});
  // final List<DropdownMenuEntry> entries = [
  //   const DropdownMenuEntry(value: 0, label: '-'),
  //   const DropdownMenuEntry(value: 1, label: 'Rudy'),
  //   const DropdownMenuEntry(value: 2, label: 'Alfin'),
  //   const DropdownMenuEntry(value: 3, label: 'Febri'),
  //   const DropdownMenuEntry(value: 4, label: 'Indra'),
  //   const DropdownMenuEntry(value: 5, label: 'Yudha'),
  // ];
  final TextEditingController dropdownC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocListener<InputserviceBloc, InputserviceState>(
          listenWhen: (pre, cur) =>
              (pre is InputserviceLoaded) && (cur is InputserviceLoaded),
          listener: (context, state) {
            if (state is InputserviceLoaded) {
              if (state.success != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiwayatPemasukan(),
                    ));
                BlocProvider.of<InputserviceBloc>(context).add(Initiate());
              }
            }
          },
          child: const Text('Groom'),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                print(await RepositoryProvider.of<PemasukanRepository>(context)
                    .getAllStruk());
              },
              icon: const Icon(Icons.bug_report))
        ],
      ),
      drawer: const SideDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var xy = BlocProvider.of<InputserviceBloc>(context).state;
          if (xy is InputserviceLoaded) {
            print(xy.karyawanName);
            if (xy.itemCards.isNotEmpty) {
              BlocProvider.of<InputserviceBloc>(context).add(SubmitToDB());
            }
          }
        },
        child: const Text(' Submit '),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            BlocBuilder<InputserviceBloc, InputserviceState>(
              builder: (context, state) {
                if (state is InputserviceLoaded) {
                  var total = 0;
                  for (var element in state.itemCards) {
                    total += element.price * (element.pcsBarang ?? 1);
                  }
                  return Text(
                      'Total : ${total.toString().numberFormat(currency: true)}');
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Text('Karyawan : '),
                Expanded(
                    child: BlocBuilder<InputserviceBloc, InputserviceState>(
                  builder: (context, state) {
                    if (state is InputserviceLoaded) {
                      print(state.karyawanName);
                      dropdownC.text = state.karyawanName;
                      return FutureBuilder(
                          future:
                              RepositoryProvider.of<KaryawanRepository>(context)
                                  .getAllKaryawan(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              List<DropdownMenuEntry<int>> a = snapshot.data!
                                  .map((e) => DropdownMenuEntry(
                                      value: e.id, label: e.namaKaryawan))
                                  .toList();
                              // a.insert(
                              //     0,
                              //     const DropdownMenuEntry(
                              //         value: -1, label: '-'));
                              return DropdownMenu<int>(
                                dropdownMenuEntries: a,
                                controller: dropdownC,
                                initialSelection: a
                                    .firstWhere(
                                      (element) =>
                                          element.label == state.karyawanName,
                                      orElse: () => const DropdownMenuEntry(
                                          value: -1, label: 'error'),
                                    )
                                    .value,
                                onSelected: (value) {
                                  BlocProvider.of<InputserviceBloc>(context)
                                      .add(ChangeKaryawan(a
                                          .firstWhere((e) => e.value == value!)
                                          .label));
                                  // dropdownC.text = a
                                  //     .firstWhere((e) => e.value == value!)
                                  //     .label;
                                },
                              );
                            } else {
                              return const Text('error snapshot');
                            }
                          });
                    } else {
                      return const Text('error');
                    }
                  },
                )),
                BlocBuilder<InputserviceBloc, InputserviceState>(
                  builder: (context, state) {
                    if (state is InputserviceLoaded) {
                      // print(state.karyawanName);
                      return Text('${state.karyawanName} ');
                    }
                    return Container();
                  },
                ),
                Text(DateTime.now().toString().substring(0, 16)),
              ],
            ),
            BlocBuilder<InputserviceBloc, InputserviceState>(
              builder: (context, state) {
                if (state is InputserviceLoaded) {
                  return Column(
                    children: [
                      for (var a in state.itemCards) ItemCard(data: a),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
            // ItemCard(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<InputserviceBloc>(context)
                            .add(AddCard());
                      },
                      child: const Text('+')),
                )
              ],
            ),
            const Center(
              child: Text('Hello world!'),
            ),
          ],
        ),
      ),
    );
  }
}
