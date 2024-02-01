import 'package:flutter/material.dart';

import 'package:groom/pages/rangkuman/rangkum_hari.dart';
import 'package:groom/pages/rangkuman/rangkum_mingg.dart';

class Rangkuman extends StatelessWidget {
  Rangkuman({super.key});
  final PageController pgController = PageController();
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: StatefulBuilder(
          builder: (context, setState) {
            return BottomNavigationBar(
              elevation: 4,
              currentIndex: idx,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.view_day), label: 'Harian'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.view_week), label: 'Mingguan'),
              ],
              onTap: (value) => pgController
                  .animateToPage(value,
                      duration: Durations.medium2, curve: Curves.easeInOut)
                  .then((v) => setState(
                        () {
                          idx = value;
                        },
                      )),
            );
          },
        ),
        appBar: AppBar(title: const Text('Rangkuman')),
        body: PageView(
          controller: pgController,
          children: const [RangkumanHarian(), RangkumanMingguan()],
        ));
  }
}
