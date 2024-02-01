import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/pages/home.dart';

import 'package:groom/pages/firstrun_setup.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null);
  var db = await SembastDB.init();
  runApp(
    MultiRepositoryProvider(providers: [
      RepositoryProvider(create: (context) => PemasukanRepository(db: db)),
      RepositoryProvider(create: (context) => KaryawanRepository(db: db)),
      RepositoryProvider(create: (context) => BonRepository(db: db)),
    ], child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future theFuture = Future(() => null);
  Future _getFirstTime() async {
    var a = await SharedPreferences.getInstance();
    var b = a.getBool('firstTime');
    if (b == null) {
      return true;
    } else {
      return b;
    }
  }

  @override
  void initState() {
    theFuture = _getFirstTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(primaryColorDark: Colors.purple[800]
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
      home: FutureBuilder(
          future: theFuture,
          builder: (context, snap) {
            if (snap.hasData) {
              if (snap.data) {
                return const FirstRun();
              } else {
                return BlocProvider(
                  create: (context) => InputserviceBloc(
                      strukrepo:
                          RepositoryProvider.of<PemasukanRepository>(context),
                      karyawanrepo:
                          RepositoryProvider.of<KaryawanRepository>(context))
                    ..add(Initiate()),
                  child: Home(),
                );
              }
            }
            return CircularProgressIndicator.adaptive();
          }),
    );
  }
}
