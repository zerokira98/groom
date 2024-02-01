import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/db/DBservice.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        actions: [
          IconButton(
              onPressed: () async {
                var a = await RepositoryProvider.of<KaryawanRepository>(context)
                    .getAllKaryawan();
                print(a);
              },
              icon: const Icon(Icons.bug_report))
        ],
      ),
    );
  }
}
