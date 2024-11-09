import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groom/blocs/cubit/theme_cubit.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/db.dart';
import 'package:groom/etc/globalvar.dart';
import 'package:groom/etc/lib/whatsapp.dart';
import 'package:groom/model/model.dart';
import 'package:groom/pages/adminapp/admin.dart';
import 'package:groom/pages/adminapp/rangkuman/rangkuman.dart';
import 'package:groom/pages/home/home.dart';

import 'package:groom/pages/firstrun_setup.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  print('message:$message');
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'no-title',
      message.notification?.body ?? 'no body',
      notificationDetails,
      payload: 'item x');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null);
  if (!kIsWeb) {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {});
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  await dotenv.load();
  runApp(RootApp());
}

class RootApp extends StatelessWidget {
  RootApp({super.key});
  final fInstance = FirebaseFirestore.instance;
  final wa = WhatsApp()
    ..setup(
      accessToken:
          '''EAAE9lyZAyIbIBOx0yT1Tvmfzvyxo4yDMa23ERHO7Jx1ZCzrYwjZCVtw5vBiQTQ6Cl5HehdEpqFmHgw30yYJ3vnjQW5ZBj0TWh66349
WPOseJ0YEKZAFn9IS9IcbjDmRQQvGHiLZAObCRrlbRbliYxSoVogtzUDQGJOrPOGf4nWzcxsjgrYsriC0aql4LMvQ1XRukTVu5bnXSTGFNfX1bcZD''',
      fromNumberId: 318587001335322,
    );

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
              create: (context) {
                return MidApi(
                    apiKey: dotenv.env['SERVER_API_KEY'] ?? '',
                    baseUrl: dotenv.env['SERVER_BASE_URL'] ?? '');
              },
              child: Container()),
          RepositoryProvider(
              create: (context) => CustomerRepo(firestore: fInstance)),
          RepositoryProvider(create: (context) => wa),
          RepositoryProvider(
              create: (context) => PemasukanRepository(db: fInstance)),
          RepositoryProvider(
              create: (context) => PengeluaranRepository(firestore: fInstance)),
          RepositoryProvider(
              create: (context) => KaryawanRepository(firestore: fInstance)),
          RepositoryProvider(
              create: (context) => ServiceItemsRepository(fInstance)),
          RepositoryProvider(create: (context) => EkuitasRepository(fInstance)),
          RepositoryProvider(create: (context) => BonRepository(db: fInstance)),
          RepositoryProvider(
              create: (context) => BarangRepository(firestore: fInstance)),
        ],
        child: MultiBlocProvider(providers: [
          BlocProvider(
              create: (context) =>
                  ThemeCubit(themeDatas: ThemeDatas())..getThemeData()),
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
        ], child: const MyApp()));
  }
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
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        FirebaseMessaging.instance.getToken().then(
          (token) async {
            print("token:$token");
            var androidId = await const AndroidId().getId();
            DeviceRepo(firestore: FirebaseFirestore.instance)
                .updateToken((androidId ?? 'unknownid'), token!);
          },
        );
        FirebaseMessaging.onMessage.listen(
          (event) async {
            print(event.notification?.title ?? 'empty');
            var flutterLocalNotificationsPlugin =
                FlutterLocalNotificationsPlugin();
            const AndroidNotificationDetails androidNotificationDetails =
                AndroidNotificationDetails('notifid', 'notifchan',
                    channelDescription: 'All notification is here',
                    importance: Importance.max,
                    priority: Priority.high,
                    ticker: 'ticker');
            const NotificationDetails notificationDetails =
                NotificationDetails(android: androidNotificationDetails);
            await flutterLocalNotificationsPlugin.show(
                0,
                event.notification?.title ?? 'no-title',
                event.notification?.body ?? 'no body',
                notificationDetails,
                payload: 'item x');
          },
        );
      }
    }
    theFuture = _getFirstTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
            title: 'Groom Barbershop',
            theme: state.themeData,
            home: BlocProvider(
                create: (context) => InputserviceBloc(
                    strukrepo:
                        RepositoryProvider.of<PemasukanRepository>(context),
                    midApi: RepositoryProvider.of<MidApi>(context),
                    karyawanrepo:
                        RepositoryProvider.of<KaryawanRepository>(context),
                    barangrepo:
                        RepositoryProvider.of<BarangRepository>(context)),
                child: FutureBuilder(
                    future: theFuture,
                    builder: (context, snap) {
                      if (snap.hasData) {
                        if (snap.data) {
                          return const FirstRun();
                        } else {
                          return adminonly ? const AdminPage() : const Home();
                        }
                      }
                      return const CircularProgressIndicator.adaptive();
                    })));
      },
    );
  }
}
