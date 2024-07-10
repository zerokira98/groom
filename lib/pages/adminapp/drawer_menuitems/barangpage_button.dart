part of '../admin.dart';

class BarangPageButton extends StatelessWidget {
  const BarangPageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_grocery_store_rounded),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Atur Barang'),
        ],
      ),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const BarangPage(),
            ));
      },
    );
  }
}
