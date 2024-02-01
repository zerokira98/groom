import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';

class BonPage extends StatelessWidget {
  const BonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bon/Piutang'),
      ),
      body: PageView(children: [
        ///show all active(?) bon
        FutureBuilder(
          future: RepositoryProvider.of<BonRepository>(context).getAllBon(),
          builder: (context, snapshot) {
            return CircularProgressIndicator();
          },
        ),

        ///show addbonpage

        ///show bayarbonpage
      ]),
    );
  }
}

class BonAddPage extends StatelessWidget {
  const BonAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///Dropdown : tipe=>[@default karyawan, lainnya]
        ///if karyawan=> show karyawan dropdown pick
        ///if lainnya=> show Textbox:subjek ,autocomplete
        ///Textbox: jumlah
      ],
    );
  }
}

class BonDecreasePage extends StatelessWidget {
  const BonDecreasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///Dropdown : tipe=>[@default karyawan, lainnya]
        ///if karyawan=> show karyawan dropdown pick
        ///if lainnya=> show Textbox:subjek ,autocomplete
        ///Textbox: jumlah
      ],
    );
  }
}
