import 'dart:io';

// import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:groom/blocs/cubit/serviceitems_cubit.dart';
import 'package:groom/db/db.dart';
// import 'package:groom/db/db.dart';
import 'package:groom/db/filedb.dart';
import 'package:groom/etc/extension.dart';
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
      appBar: AppBar(title: const Text('Edit&Tambah Menu')),
      body: Center(
        child: BlocBuilder<ServiceitemsCubit, ServiceitemsState>(
          builder: (context, state) {
            List<Widget> children =
                (state.datas.map<Widget>((val) {
                  // var e/ = val.title;
                  return ItemCardBox(
                    val,
                    ontap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            MenueditDialog(edit: true, data: val),
                      );
                    },
                  );
                }).toList())..add(
                  InkWell(
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
                          ),
                        ),
                      ),
                    ),
                  ),
                );
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menues',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(padding: EdgeInsetsGeometry.all(4)),
                        Wrap(
                          runAlignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          alignment: WrapAlignment.start,
                          spacing: 16,
                          runSpacing: 16,
                          children: children,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: (state.status == Status.loading)
                      ? CircularProgressIndicator()
                      : Column(
                          children: [
                            Text('Categories'),
                            Expanded(
                              child: ReorderableListView.builder(
                                onReorder: (oldIndex, newIndex) async {
                                  if (newIndex > state.categories.length) {
                                    throw Exception();
                                  }
                                  var newlist = List.from(
                                    state.categories,
                                  ).map((e) => e).toList();
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  // Remove the item from its original position
                                  final item = newlist.removeAt(oldIndex);
                                  // Insert the item into its new position
                                  newlist.insert(newIndex, item);
                                  print(newlist.map((e) => e['title']));
                                  print(newlist.map((e) => e['orderindex']));
                                  for (var e = 0; e < newlist.length; e++) {
                                    print(newlist[e].data()['id']);
                                    await RepositoryProvider.of<
                                          ServiceItemsRepository
                                        >(context)
                                        .updateOrder(
                                          newlist[e].data()['id'],
                                          e,
                                        );
                                  }
                                  BlocProvider.of<ServiceitemsCubit>(
                                    context,
                                  ).initiate();
                                  print('here');
                                },
                                itemCount: state.categories.length + 1,
                                itemBuilder: (context, index) =>
                                    index != state.categories.length
                                    ? ListTile(
                                        trailing: IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('danger'),
                                                content: Text('r u sure?'),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      BlocProvider.of<
                                                            ServiceitemsCubit
                                                          >(context)
                                                          .deleteCategory(
                                                            state
                                                                .categories[index]
                                                                .id,
                                                          );
                                                    },
                                                    child: Text('Ok'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.delete_outline),
                                        ),
                                        key: Key(state.categories[index].id),
                                        title: Text(
                                          state.categories[index]['title'],
                                        ),
                                        onTap: () {
                                          TextEditingController titlecon =
                                              TextEditingController(
                                                text: state
                                                    .categories[index]['title'],
                                              );
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    BlocProvider.of<
                                                          ServiceitemsCubit
                                                        >(context)
                                                        .editCategory(
                                                          titlecon.text,
                                                          state
                                                              .categories[index]['id'],
                                                        );
                                                  },
                                                  child: Text('Edit'),
                                                ),
                                              ],
                                              content: TextFormField(
                                                controller: titlecon,
                                                decoration: InputDecoration(
                                                  label: Text('Nama kategori'),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : ElevatedButton(
                                        key: Key('addbutt'),
                                        onPressed: () {
                                          TextEditingController titlecon =
                                              TextEditingController();
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                BlocListener<
                                                  ServiceitemsCubit,
                                                  ServiceitemsState
                                                >(
                                                  listener: (context, state) {
                                                    if (state.status ==
                                                        Status.error) {
                                                      Flushbar(
                                                        message:
                                                            state.msg!['msg'],
                                                        duration:
                                                            const Duration(
                                                              seconds: 2,
                                                            ),
                                                        animationDuration:
                                                            Durations.long1,
                                                      ).show(context).then((
                                                        value,
                                                      ) {
                                                        BlocProvider.of<
                                                              ServiceitemsCubit
                                                            >(context)
                                                            .clrMsg();
                                                      });
                                                    }
                                                  },
                                                  child: AlertDialog(
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          BlocProvider.of<
                                                                ServiceitemsCubit
                                                              >(context)
                                                              .addCategory(
                                                                titlecon.text,
                                                              );
                                                        },
                                                        child: Text('Ok'),
                                                      ),
                                                    ],
                                                    content: TextFormField(
                                                      controller: titlecon,
                                                      decoration:
                                                          InputDecoration(
                                                            label: Text(
                                                              'Nama kategori',
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                          );
                                        },
                                        child: Text('Add Category'),
                                      ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
            // }
            // return CircularProgressIndicator.adaptive();
          },
        ),
      ),
    );
  }
}

class MenueditDialog extends StatefulWidget {
  final bool edit;
  final ServiceitemsMdl? data;
  const MenueditDialog({this.edit = false, super.key, this.data});

  @override
  State<MenueditDialog> createState() => _MenueditDialogState();
}

class _MenueditDialogState extends State<MenueditDialog> {
  GlobalKey<FormState> key = GlobalKey();
  TextEditingController namaMenu = TextEditingController();
  TextEditingController harga = TextEditingController();
  TextEditingController employeeCutController = TextEditingController();

  dynamic selectedimg;

  bool ispercentage = false;
  String dropdownvalue = '';
  void dropdownChange(String? title) {
    setState(() {
      dropdownvalue = title ?? '';
    });
  }

  @override
  void initState() {
    if (widget.data != null) {
      selectedimg = widget.data!.img != null ? File(widget.data!.img!) : null;
      namaMenu.text = widget.data!.title;
      harga.text = widget.data!.price.toString();
      employeeCutController.text = widget.data!.employeeCut.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceitemsCubit, ServiceitemsState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          BlocProvider.of<ServiceitemsCubit>(context).initiate();
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: Text(widget.edit ? 'Edit menu' : 'Tambah menu'),
        content: Form(
          key: key,
          child: Row(
            children: [
              SizedBox(
                width:
                    MediaQuery.sizeOf(context).width /
                    ((MediaQuery.orientationOf(context).index + 1) * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
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
                            decoration: const InputDecoration(
                              label: Text('Nama menu'),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsetsGeometry.all(2)),
                        Flexible(
                          child: CategoryOptions(onchanged: dropdownChange),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(4)),
                    Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            controller: harga,
                            keyboardType: TextInputType.number,
                            validator: (value) => switch (value) {
                              String() when int.tryParse(value) == null =>
                                "Bukan angka",
                              String() when value.isEmpty =>
                                "Tidak boleh kosong",
                              null => null,
                              String() => null,
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              label: Text('Harga'),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(2)),
                        Padding(padding: EdgeInsets.all(2)),
                        (ispercentage)
                            ? PercentageField(
                                employeeCutController: employeeCutController,
                                percentstate: () {
                                  if (ispercentage) {
                                    setState(() {
                                      employeeCutController.text =
                                          (double.parse(
                                                    employeeCutController.text,
                                                  ) *
                                                  int.parse(harga.text))
                                              .round()
                                              .toString();
                                      ispercentage = false;
                                    });
                                  }
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              )
                            : Flexible(
                                child: TextFormField(
                                  controller: employeeCutController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => switch (value) {
                                    String() when int.tryParse(value) == null =>
                                      "Bukan angka valid",
                                    String() when value.isEmpty =>
                                      "Tidak boleh kosong",
                                    null => null,
                                    String() => null,
                                  },
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    label: Text('for employee'),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        if (!ispercentage) {
                                          var ratio =
                                              (int.tryParse(
                                                    employeeCutController.text,
                                                  ) ??
                                                  0) /
                                              (int.tryParse(harga.text) ?? 0);
                                          setState(() {
                                            employeeCutController.text = ratio
                                                .toString();
                                            ispercentage = true;
                                          });
                                        }
                                      },
                                      child: Icon(Icons.change_circle_outlined),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    if (!ispercentage)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ratio: ${(int.tryParse(employeeCutController.text) ?? 0) / (int.tryParse(harga.text) ?? 0)}',
                          ),
                          Text(
                            'for owner: ${((int.tryParse(harga.text) ?? 0) - (int.tryParse(employeeCutController.text) ?? 0)).numberFormat(currency: true)}',
                          ),
                        ],
                      ),
                    if (ispercentage)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'for employee:${((double.tryParse(employeeCutController.text) ?? 1) * (int.tryParse(harga.text) ?? 0)).numberFormat(currency: true)}',
                          ),
                          Text(
                            'for owner:${((1 - (double.tryParse(employeeCutController.text) ?? 1)) * (int.tryParse(harga.text) ?? 0)).numberFormat(currency: true)}',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(4)),
              InkWell(
                onTap: () async {
                  var file = await FilePicker.platform.pickFiles(
                    type: FileType.media,
                  );
                  print(file!.files[0].size);
                  var createdData = await FlutterImageCompress.compressWithFile(
                    file.files[0].path!,
                    minHeight: 110,
                    minWidth: 110,
                  );
                  var dirpath = await getApplicationDocumentsDirectory();
                  var createdFile = await File(
                    path.join(dirpath.path, 'tempdata.png'),
                  ).create().then((value) => value.writeAsBytes(createdData!));
                  setState(() {
                    selectedimg = createdFile;
                  });
                },
                child: Card(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: selectedimg == null
                        ? const Center(
                            child: Text(
                              'add img icon\n+',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Image(
                            image: FileImage(selectedimg as File),
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('img/logo.jpg');
                            },
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              var valid = key.currentState!.validate();
              if (valid) {
                if (selectedimg != null) {
                  print(valid);
                  var newfilepath = await FileRepo().uploadFile(
                    selectedimg,
                    namaMenu.text,
                  );
                  // var test =
                  //     await RepositoryProvider.of<ServiceItemsRepository>(
                  //       context,
                  //     ).getItems().then((value) {
                  //       return value.sorted((a, b) => a.id.compareTo(b.id));
                  //     });
                  // var test = value.sorted(
                  //   (a, b) => a.type.compareTo(b.type),
                  // );
                  // print(test);
                  if (widget.edit == false) {
                    BlocProvider.of<ServiceitemsCubit>(context).addItem(
                      ServiceitemsMdl(
                        title: namaMenu.text,
                        img: newfilepath,
                        employeeCut: ispercentage
                            ? (double.parse(employeeCutController.text) *
                                      int.parse(harga.text))
                                  .round()
                            : int.parse(employeeCutController.text),
                        price: int.parse(harga.text),
                      ),
                    );
                  } else {
                    // Flushbar(
                    //   // title: 'unimplemented',
                    //   message: 'unimplemented',
                    //   duration: Duration(seconds: 2),
                    // ).show(context);

                    BlocProvider.of<ServiceitemsCubit>(context).editItem(
                      widget.data!.copyWith(
                        title: namaMenu.text,
                        img: () => newfilepath,
                        employeeCut: () => ispercentage
                            ? (double.parse(employeeCutController.text) *
                                      int.parse(harga.text))
                                  .round()
                            : int.parse(employeeCutController.text),
                        price: int.parse(harga.text),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(widget.edit ? 'Edit' : 'Add'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class PercentageField extends StatelessWidget {
  final TextEditingController employeeCutController;
  final Function(dynamic value) onChanged;
  final Function() percentstate;
  const PercentageField({
    super.key,
    required this.employeeCutController,
    required this.onChanged,
    required this.percentstate,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        controller: employeeCutController,
        keyboardType: TextInputType.number,
        validator: (value) => switch (value) {
          String() when double.tryParse(value) == null => "Bukan angka valid",
          String() when value.isEmpty => "Tidak boleh kosong",
          null => null,
          String() => null,
        },
        onChanged: onChanged,
        decoration: InputDecoration(
          label: Text('cut percent'),
          suffixIcon: InkWell(
            onTap: percentstate,
            child: Icon(Icons.change_circle_outlined),
          ),
        ),
      ),
    );
  }
}

class CategoryOptions extends StatelessWidget {
  final void Function(String? title)? onchanged;
  const CategoryOptions({super.key, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceitemsCubit, ServiceitemsState>(
      builder: (context, state) {
        print(state.categories);
        return DropdownButtonFormField(
          decoration: InputDecoration(label: Text('Category')),
          items: state.categories
              .map(
                (e) => DropdownMenuItem(
                  value: e.data()['title'] as String,
                  child: Text((e.data() as Map?)?['title'] ?? ''),
                ),
              )
              .toList(),
          onChanged: onchanged,
        );
      },
    );
  }
}
