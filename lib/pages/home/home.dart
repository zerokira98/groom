import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/db.dart';
import 'package:groom/pages/adminapp/servicemenu/servicemenuedit.dart';
import 'package:groom/pages/home/widgets/bottombar.dart';
import 'package:groom/pages/home/widgets/drawer.dart';
import 'package:groom/pages/home/widgets/home_appbar.dart';

import 'package:groom/model/model.dart';
import 'package:groom/pages/home/riwayat_pemasukan/riwayat_masuk_home.dart';
import 'package:groom/pages/home/widgets/itemcard_box.dart';
import 'package:groom/pages/home/widgets/listtile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    BlocProvider.of<InputserviceBloc>(context).add(Initiate());
    super.initState();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 48,
      drawer: const SideDrawer(),
      // floatingActionButton: BlocBuilder<InputserviceBloc, InputserviceState>(
      //   builder: (context, state) {
      //     return FloatingButton(formstate: formKey);
      //   },
      // ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (kIsWeb &&
          //     MediaQuery.of(context).orientation == Orientation.portrait)
          //   Builder(builder: (context) {
          //     return IconButton(
          //       onPressed: () {
          //         Scaffold.of(context).openDrawer();
          //       },
          //       icon: const Icon(Icons.view_list_sharp),
          //     );
          //   }),
          if (kIsWeb &&
              MediaQuery.of(context).orientation == Orientation.landscape)
            const SideDrawer(),
          Expanded(
            child: BlocListener<InputserviceBloc, InputserviceState>(
              listenWhen: (pre, cur) =>
                  (pre is InputserviceLoading) && (cur is InputserviceLoaded),
              listener: (context, state) {
                if (state is InputserviceLoaded) {
                  if (state.success != null) {
                    if (state.tipePembayaran == TipePembayaran.qris) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                              'QRCODE VIEW ${jsonDecode(state.success!)['qrcode_url']}'),
                          content: Image.network(
                              jsonDecode(state.success!)['qrcode_url']),
                        ),
                      );
                    } else {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const RiwayatPemasukan(),
                          ));
                    }
                    BlocProvider.of<InputserviceBloc>(context).add(Initiate());
                  } else if (state.err != null) {
                    Flushbar(
                      message: state.err,
                      duration: const Duration(seconds: 2),
                      animationDuration: Durations.long1,
                    ).show(context).then(
                      (value) {
                        //     BlocProvider.of<InputserviceBloc>(context)
                        //        .add(Initiate());
                      },
                    );
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: (kIsWeb &&
                            MediaQuery.of(context).orientation ==
                                Orientation.landscape)
                        ? 4
                        : 0),
                child: Stack(
                  children: [
                    OfflineBuilder(
                      errorBuilder: (context) =>
                          const Text('err no connection'),
                      connectivityBuilder: (context, value, child) => Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedPositioned(
                            duration: Durations.extralong4,
                            curve: const Interval(0.5, 1.0,
                                curve: Curves.easeInOut),
                            height: !value.contains(ConnectivityResult.none)
                                ? 0
                                : 24,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              color: !value.contains(ConnectivityResult.none)
                                  ? const Color(0xFF00EE44)
                                  : const Color(0xFFEE4400),
                              child: Center(
                                child: Text(
                                    !value.contains(ConnectivityResult.none)
                                        ? 'ONLINE'
                                        : 'OFFLINE MODE'),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Durations.extralong4,
                            curve: const Interval(0.5, 1.0,
                                curve: Curves.easeInOut),
                            padding: EdgeInsets.only(
                                top: !value.contains(ConnectivityResult.none)
                                    ? 0.0
                                    : 26.0),
                            child: child,
                          )
                        ],
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          BlocProvider.of<InputserviceBloc>(context)
                              .add(Initiate());
                          return Future.delayed(
                              Durations.extralong4, () => true);
                        },
                        child: Column(
                          children: [
                            HomeAppbar(),
                            const Padding(padding: EdgeInsets.all(6)),
                            Expanded(
                              child: BlocBuilder<InputserviceBloc,
                                  InputserviceState>(
                                builder: (context, state) {
                                  if (state is InputserviceLoaded) {
                                    if (state.itemCards.isNotEmpty) {
                                      return ListView.builder(
                                        itemCount: state.itemCards.length,
                                        itemBuilder: (context, a) {
                                          return MyListTile(state.itemCards[a]);
                                        },
                                      );
                                    } else {
                                      return const Text('Empty');
                                    }
                                  } else {
                                    return const Text('Hi');
                                  }
                                },
                              ),
                            ),
                            const BottombarHome(),
                            FutureBuilder(
                                future: RepositoryProvider.of<
                                        ServiceItemsRepository>(context)
                                    .getItems(),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.done:
                                      if (snapshot.hasData &&
                                          (snapshot.data as List).isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Wrap(
                                            alignment: WrapAlignment.start,
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: [
                                              for (var a = 0;
                                                  a < cardType.length;
                                                  a++)
                                                ItemCardBox(cardType[a]),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ServicemenueditPage()));
                                            },
                                            child: const Text(
                                                'Empty menu items, click here to add'));
                                      }
                                    case ConnectionState.waiting:
                                      return const CircularProgressIndicator();
                                    default:
                                      return Container();
                                  }
                                }),
                            const Padding(padding: EdgeInsets.all(12)),
                          ],
                        ),
                      ),
                    ),
                    // Positioned(
                    //     bottom: 0, left: 0, right: 0, child: BottombarHome()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
