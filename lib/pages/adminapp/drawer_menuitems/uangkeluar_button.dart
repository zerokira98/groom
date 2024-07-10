part of '../admin.dart';

class UangKeluarButton extends StatelessWidget {
  const UangKeluarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          Text('Uang Keluar'),
        ],
      ),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const UangKeluarPage(),
            ));
      },
    );
  }
}
