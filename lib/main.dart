import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/DBservice.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkuman.dart';
import 'package:groom/pages/home/home.dart';

import 'package:groom/pages/firstrun_setup.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null);
  var db = await SembastDB.init();
  var db2 = await SembastDB.init2();
  runApp(
    MultiRepositoryProvider(providers: [
      RepositoryProvider(create: (context) => PemasukanRepository(db: db)),
      RepositoryProvider(create: (context) => PengeluaranRepository(db: db2)),
      RepositoryProvider(create: (context) => KaryawanRepository(db: db)),
      RepositoryProvider(create: (context) => EkuitasRepository(db2)),
      RepositoryProvider(create: (context) => BonRepository(db: db2)),
      RepositoryProvider(create: (context) => BarangRepository(db: db2)),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InputserviceBloc(
              strukrepo: RepositoryProvider.of<PemasukanRepository>(context),
              karyawanrepo: RepositoryProvider.of<KaryawanRepository>(context)),
        ),
        BlocProvider(
          create: (context) => RangkumanWeekCubit(
              RepositoryProvider.of<PemasukanRepository>(context),
              RepositoryProvider.of<BonRepository>(context)),
        ),
        BlocProvider(
          create: (context) => RangkumanDayCubit(
              RepositoryProvider.of<PemasukanRepository>(context),
              RepositoryProvider.of<PengeluaranRepository>(context)),
        ),
        BlocProvider(
          create: (context) => BulananCubit(
              RepositoryProvider.of<PemasukanRepository>(context),
              RepositoryProvider.of<PengeluaranRepository>(context)),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme:
            ThemeData.dark().copyWith(primaryColorDark: Colors.purple[800]),
        home: FutureBuilder(
            future: theFuture,
            builder: (context, snap) {
              if (snap.hasData) {
                if (snap.data) {
                  return const FirstRun();
                } else {
                  return BlocProvider.value(
                    value: BlocProvider.of<InputserviceBloc>(context)
                      ..add(Initiate()),
                    child: Home(),
                  );
                }
              }
              return const CircularProgressIndicator.adaptive();
            }),
      ),
    );
  }
}
