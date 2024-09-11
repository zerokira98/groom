part of '../admin.dart';

class BonPageButton extends StatelessWidget {
  const BonPageButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap ??
          () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const BonPage(),
                ));
          },
      child: const Text('Bon / Piutang'),
    );
  }
}
