part of '../admin.dart';

class ServicemenuitemButton extends StatelessWidget {
  const ServicemenuitemButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServicemenueditPage(),
            ));
      },
      child: const Text('Service Menues'),
    );
  }
}
