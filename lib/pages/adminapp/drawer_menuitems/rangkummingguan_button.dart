part of '../admin.dart';

class RangkumMingguanButton extends StatelessWidget {
  const RangkumMingguanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        children: [
          Icon(Icons.calendar_view_week),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Rangkuman Mingguan'),
        ],
      ),
      onPressed: () {
        var valueWidget = BlocProvider.value(
          value: BlocProvider.of<RangkumanWeekCubit>(context)
            ..loadData({
              'tanggalStart': DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day)
                  .subtract(Duration(
                days: DateTime.now().weekday,
              )),
              'tanggalEnd': DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day)
                  .subtract(Duration(
                    days: DateTime.now().weekday,
                  ))
                  .add(const Duration(days: 7)),
            }),
          child: const RangkumanMingguan(),
          // ),
        );
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => valueWidget,
          ),
        );
      },
    );
  }
}
