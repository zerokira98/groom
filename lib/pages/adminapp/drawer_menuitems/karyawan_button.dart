part of '../admin.dart';

class KaryawanButton extends StatelessWidget {
  const KaryawanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.supervised_user_circle),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Atur Karyawan'),
        ],
      ),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const KaryawanConfig(),
            ));
      },
    );
  }
}
