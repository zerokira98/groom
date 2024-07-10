part of '../admin.dart';

class RangkumBulananButton extends StatelessWidget {
  const RangkumBulananButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        children: [
          Icon(Icons.calendar_view_month),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Rangkuman Bulanan'),
        ],
      ),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => BlocProvider.value(
                value: BlocProvider.of<BulananCubit>(context)
                  ..loadData(DateTime.now()),
                child: const RangkumMonth(),
              ),
            ));
      },
    );
  }
}
