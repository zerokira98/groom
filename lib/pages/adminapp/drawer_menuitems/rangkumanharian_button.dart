part of '../admin.dart';

class RangkumHarianButton extends StatelessWidget {
  const RangkumHarianButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        children: [
          Icon(Icons.calendar_view_day),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Rangkuman Harian'),
        ],
      ),
      onPressed: () {
        var valueWidget = BlocProvider.value(
          value: BlocProvider.of<RangkumanDayCubit>(context)
            ..loadData({
              'tanggalStart': DateTime.now(),
              'tanggalEnd': DateTime.now().addDays(1),
            }),
          child: const RangkumanHarian(),
        );
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => valueWidget));
      },
    );
  }
}
