import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:groom/db/db.dart';
import 'package:groom/db/filedb.dart';
import 'package:groom/model/serviceitems_mdl.dart';
import 'package:groom/pages/home/widgets/itemcard_box.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ServicemenueditPage extends StatefulWidget {
  const ServicemenueditPage({super.key});

  @override
  State<ServicemenueditPage> createState() => _ServicemenueditPageState();
}

class _ServicemenueditPageState extends State<ServicemenueditPage> {
  String selected = 'a';
  @override
  Widget build(BuildContext context) {
    print(selected);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit&Tambah Menu'),
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(4)),
            FutureBuilder(
                future: RepositoryProvider.of<ServiceItemsRepository>(context)
                    .getItems(),
                builder: (context, snapshot) {
                  // if (snapshot.hasError || snapshot.data!.isEmpty) {
                  //   return Text('error or empty');
                  // } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  var data = snapshot.data ?? [];
                  List<Widget> children = (data.map<Widget>(
                    (val) {
                      var e = val.title;
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              selected = e;
                            });
                          },
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.black54,
                                  selected == e
                                      ? BlendMode.color
                                      : BlendMode.dstOver),
                              child: AbsorbPointer(child: ItemCardBox(e))));
                    },
                  ).toList())
                    ..add(InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const MenueditDialog(),
                        );
                      },
                      child: const Card(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                              child: Text(
                            '+\nTambah Item',
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                    ));
                  return Wrap(
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.start,
                      spacing: 16,
                      runSpacing: 16,
                      children: children);
                  // }
                  // return CircularProgressIndicator.adaptive();
                }),
          ],
        ),
      ),
    );
  }
}

class MenueditDialog extends StatefulWidget {
  final bool edit;
  const MenueditDialog({this.edit = false, super.key});

  @override
  State<MenueditDialog> createState() => _MenueditDialogState();
}

class _MenueditDialogState extends State<MenueditDialog> {
  GlobalKey<FormState> key = GlobalKey();
  TextEditingController namaMenu = TextEditingController();
  TextEditingController harga = TextEditingController();

  dynamic selectedimg;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.edit ? 'Edit menu' : 'Tambah menu'),
      content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaMenu,
                keyboardType: TextInputType.text,
                validator: (value) {
                  switch (value) {
                    case null:
                      return null;
                    case String() when value.length < 3:
                      return "Terlalu pendek";
                    case String() when value.isEmpty:
                      return "Tidak boleh kosong";
                    default:
                      return null;
                  }
                },
                decoration: const InputDecoration(label: Text('Nama menu')),
              ),
              const Padding(padding: EdgeInsets.all(4)),
              TextFormField(
                controller: harga,
                keyboardType: TextInputType.number,
                validator: (value) => switch (value) {
                  String() when int.tryParse(value) == null => "Bukan angka",
                  String() when value.isEmpty => "Tidak boleh kosong",
                  null => null,
                  String() => null,
                },
                decoration: const InputDecoration(
                    label: Text('Harga'), icon: Text("Rp.")),
              ),
              InkWell(
                onTap: () async {
                  var file =
                      await FilePicker.platform.pickFiles(type: FileType.media);
                  print(file!.files[0].size);
                  var createdData = await FlutterImageCompress.compressWithFile(
                      file.files[0].path!,
                      minHeight: 110,
                      minWidth: 110);
                  var dirpath = await getApplicationDocumentsDirectory();
                  var createdFile =
                      await File(path.join(dirpath.path, 'tempdata.png'))
                          .create()
                          .then((value) => value.writeAsBytes(createdData!));
                  setState(() {
                    selectedimg = createdFile;
                  });
                },
                child: Card(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: selectedimg == null
                        ? Center(
                            child: Text(
                            'add img icon\n+',
                            textAlign: TextAlign.center,
                          ))
                        : Image(
                            image: FileImage(selectedimg as File),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              )
            ],
          )),
      actions: [
        ElevatedButton(
            onPressed: () async {
              var valid = key.currentState!.validate();
              print(valid);
              if (valid) {
                if (selectedimg != null) {
                  var filepath =
                      await FileRepo().uploadFile(selectedimg, namaMenu.text);
                  var test =
                      await RepositoryProvider.of<ServiceItemsRepository>(
                              context)
                          .getItems()
                          .then((value) {
                    return value.sorted(
                      (a, b) => a.type.compareTo(b.type),
                    );
                  });
                  // var test = value.sorted(
                  //   (a, b) => a.type.compareTo(b.type),
                  // );
                  print(test);
                  // RepositoryProvider.of<ServiceItemsRepository>(context)
                  //     .addItem(ServiceitemsMdl(
                  //         title: namaMenu.text,
                  //         type: type,
                  //         price: int.parse(harga.text)));
                }
              }
            },
            child: const Text('Add')),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'))
      ],
    );
  }
}
