part of '../admin.dart';

class GantiPassAdmin extends StatelessWidget {
  GantiPassAdmin({super.key, this.onTap});
  final Function()? onTap;
  final GlobalKey<FormState> formkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.supervised_user_circle),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text('Ganti Password Admin'),
        ],
      ),
      onPressed: () {
        TextEditingController tc = TextEditingController();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Caution!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (formkey.currentState?.validate() ?? false) {
                    SharedPreferences.getInstance().then((spref) {
                      spref
                          .setString('adminpass', tc.text)
                          .then(
                            (value) => value
                                ? Navigator.pop(context)
                                : Navigator.pop(context),
                          );
                      return null;
                    });
                  }
                },
                child: const Text('Ubah'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
            ],
            content: Form(
              key: formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('jangan sampai terlupa'),
                  const Text('Password baru'),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null) return null;
                      if (value.length <= 3) {
                        return '4 or more char';
                      }
                      if (!value.contains(RegExp(r'^\d+$'))) {
                        return 'non number exist';
                      }
                      return null;
                    },
                    controller: tc,
                  ),
                  const Text('Ketik ulang'),
                  TextFormField(
                    validator: (value) {
                      if (value == null) return null;
                      if (value != tc.text) {
                        return 'not same';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
