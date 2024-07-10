part of '../admin.dart';

class BonPageButton extends StatelessWidget {
  const BonPageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Bon / Piutang'),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const BonPage(),
            ));
      },
    );
  }
}
