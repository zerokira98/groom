part of '../admin.dart';

class EkuitasPageButton extends StatelessWidget {
  const EkuitasPageButton({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap ??
          () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const EkuitasPage(),
                ));
          },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          Text('Uang Masuk'),
        ],
      ),
    );
  }
}
