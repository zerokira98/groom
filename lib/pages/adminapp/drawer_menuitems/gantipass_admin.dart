part of '../admin.dart';

class GantiPassAdmin extends StatelessWidget {
  const GantiPassAdmin({super.key});

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
                    SharedPreferences.getInstance().then((spref) {
                      spref.setString('adminpass', tc.text).then((value) =>
                          value
                              ? Navigator.pop(context)
                              : Navigator.pop(context));
                      return null;
                    });
                  },
                  child: const Text('Ubah')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal')),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('jangan sampai terlupa'),
                const Text('Password baru'),
                TextFormField(
                  validator: (value) {
                    if (value == null) return null;
                    if (value.length <= 3) {
                      return '4 or more char';
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
        );
      },
    );
  }
}
