import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/barang_repo.dart';
import 'package:groom/db/db_service.dart';
import 'package:groom/db/bon_repo.dart';
import 'package:groom/db/karyawan_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';
import 'package:groom/db/pengeluaran_repo.dart';
import 'package:groom/db/uangmasuk_repo.dart';
import 'package:groom/etc/globalvar.dart';
import 'package:groom/pages/adminapp/admin.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkuman.dart';
import 'package:groom/pages/home/home.dart';

import 'package:groom/pages/firstrun_setup.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var fInstance = FirebaseFirestore.instance;
  var db = await SembastDB.init();
  var db2 = await SembastDB.init2();
  runApp(
    MultiRepositoryProvider(providers: [
      RepositoryProvider(
          create: (context) => PemasukanRepository(db: fInstance)),
      RepositoryProvider(
          create: (context) =>
              PengeluaranRepository(firestore: fInstance, db: db2)),
      RepositoryProvider(
          create: (context) =>
              KaryawanRepository(db: db, firestore: fInstance)),
      RepositoryProvider(
          create: (context) => EkuitasRepository(db2, fInstance)),
      RepositoryProvider(create: (context) => BonRepository(db: fInstance)),
      RepositoryProvider(
          create: (context) => BarangRepository(db: db2, firestore: fInstance)),
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
              karyawanrepo: RepositoryProvider.of<KaryawanRepository>(context),
              barangrepo: RepositoryProvider.of<BarangRepository>(context)),
        ),
        BlocProvider(
          create: (context) => RangkumanWeekCubit(
              RepositoryProvider.of<PemasukanRepository>(context),
              RepositoryProvider.of<BonRepository>(context),
              RepositoryProvider.of<PengeluaranRepository>(context)),
        ),
        BlocProvider(
          create: (context) => RangkumanDayCubit(
              RepositoryProvider.of<PemasukanRepository>(context),
              RepositoryProvider.of<PengeluaranRepository>(context),
              RepositoryProvider.of<BonRepository>(context)),
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
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.deepPurple.shade800),
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
                    child: adminonly ? const AdminPage() : Home(),
                  );
                }
              }
              return const CircularProgressIndicator.adaptive();
            }),
      ),
    );
  }
}
