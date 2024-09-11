part of '../admin.dart';

class CatatPengeluaranButton extends StatelessWidget {
  const CatatPengeluaranButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap ??
          () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const PengeluaranPage(),
                ));
          },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit),
          Padding(padding: EdgeInsets.only(right: 4)),
          Text('Catat Pengeluaran'),
        ],
      ),
    );
  }
}
