part of '../admin.dart';

class BarangPageButton extends StatelessWidget {
  const BarangPageButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap ??
          () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const BarangPage(),
                ));
          },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_grocery_store_rounded),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Atur Barang'),
        ],
      ),
    );
  }
}
