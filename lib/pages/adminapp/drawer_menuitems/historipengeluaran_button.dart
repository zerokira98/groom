part of '../admin.dart';

class HistoriPengeluaranButton extends StatelessWidget {
  const HistoriPengeluaranButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap ??
          () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const HistoriPengeluaran(),
                ));
          },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history),
          Padding(padding: EdgeInsets.only(right: 4)),
          Text('Histori Pengeluaran'),
        ],
      ),
    );
  }
}
