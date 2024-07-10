part of '../admin.dart';

class EkuitasPageButton extends StatelessWidget {
  const EkuitasPageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          Text('Uang Masuk'),
        ],
      ),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const EkuitasPage(),
            ));
      },
    );
  }
}
