part of '../admin.dart';

class UangKeluarButton extends StatelessWidget {
  const UangKeluarButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap ??
          () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const UangKeluarPage(),
                ));
          },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          Text('Uang Keluar'),
        ],
      ),
    );
  }
}
