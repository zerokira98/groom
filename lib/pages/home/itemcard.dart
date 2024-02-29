import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/db/barang_repo.dart';
import 'package:groom/db/pemasukan_repo.dart';

import 'package:groom/model/model.dart';

class ItemCard extends StatelessWidget {
  final ItemCardMdl data;
  const ItemCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Service : '),
                DropdownMenu(
                  dropdownMenuEntries: [
                    for (int i = 0; i < cardType.length; i++)
                      DropdownMenuEntry(label: cardType[i], value: i)
                  ],
                  initialSelection: data.type,
                  onSelected: (value) {
                    BlocProvider.of<InputserviceBloc>(context)
                        .add(ChangeItemType(idx: data.index, type: value!));
                  },
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<InputserviceBloc>(context)
                          .add(RemoveCard(data));
                    },
                    icon: const Icon(Icons.delete_rounded))
              ],
            ),
            switch (data.type) {
              0 => ItemCardHaircut(data),
              1 => ItemCardShave(data),
              2 => ItemCardColoring(data),
              3 => ItemCardGoods(data),
              4 => ItemCardOthers(data),
              int() => Container(
                  child: const Text('error switch'),
                )
            }
          ],
        ),
      ),
    );
  }
}

class ItemCardHaircut extends StatefulWidget {
  final ItemCardMdl data;
  const ItemCardHaircut(this.data, {super.key});

  @override
  State<ItemCardHaircut> createState() => _ItemCardHaircutState();
}

class _ItemCardHaircutState extends State<ItemCardHaircut> {
  int basicHaircut = 20000;

  int keramasPrice = 5000;

  bool keramas = false;
  int total() {
    return keramas ? basicHaircut + keramasPrice : basicHaircut;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Keramas?'),
            Checkbox(
              value: keramas,
              onChanged: (value) {
                setState(() {
                  keramas = value!;
                  BlocProvider.of<InputserviceBloc>(context)
                      .add(ChangePrice(idx: widget.data.index, price: total()));
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Biaya : '),

            ///make it textfield
            Text((keramas ? basicHaircut + keramasPrice : basicHaircut)
                .toString())
          ],
        ),
      ],
    );
  }
}

class ItemCardShave extends StatefulWidget {
  final ItemCardMdl data;
  const ItemCardShave(this.data, {super.key});

  @override
  State<ItemCardShave> createState() => _ItemCardShaveState();
}

class _ItemCardShaveState extends State<ItemCardShave> {
  final int basicPrice = 5000;

  final int extraService = 5000;

  bool extra = false;

  int total() {
    return extra ? basicPrice + extraService : basicPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Extra?'),
            Checkbox(
              value: extra,
              onChanged: (value) {
                setState(() {
                  extra = value!;
                  BlocProvider.of<InputserviceBloc>(context)
                      .add(ChangePrice(idx: widget.data.index, price: total()));
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Biaya : '),
            Text('${total()}'),
          ],
        )
      ],
    );
  }
}

class ItemCardColoring extends StatelessWidget {
  const ItemCardColoring(this.data, {super.key});
  final ItemCardMdl data;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Biaya : '),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  BlocProvider.of<InputserviceBloc>(context).add(
                      ChangePrice(idx: data.index, price: int.parse(value)));
                },
              ),
            ),

            // Text('xxx'),
          ],
        )
      ],
    );
  }
}

class ItemCardGoods extends StatefulWidget {
  const ItemCardGoods(this.data, {super.key});
  final ItemCardMdl data;

  @override
  State<ItemCardGoods> createState() => _ItemCardGoodsState();
}

class _ItemCardGoodsState extends State<ItemCardGoods> {
  final TextEditingController priceController = TextEditingController();

  final TextEditingController tc = TextEditingController();
  @override
  void initState() {
    priceController.text = widget.data.price.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Text('Nama Barang : '),
            Expanded(
              child: Autocomplete(
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    TextFormField(
                  controller: textEditingController,
                  onFieldSubmitted: (value) {
                    onFieldSubmitted();
                  },
                  focusNode: focusNode,
                  onChanged: (value) {
                    BlocProvider.of<InputserviceBloc>(context).add(
                        ChangeItemDetails(
                            idx: widget.data.index,
                            data: widget.data.copyWith(namaBarang: value)));
                  },
                  decoration: const InputDecoration(label: Text('Nama Barang')),
                ),
                onSelected: (option) async {
                  await RepositoryProvider.of<BarangRepository>(context)
                      .find(option)
                      .then((value) {
                    if (value.isNotEmpty) {
                      debugPrint(value.first.toString());
                      setState(() {
                        priceController.text = value.first.hargajual.toString();
                      });
                      BlocProvider.of<InputserviceBloc>(context).add(
                          ChangeItemDetails(
                              idx: widget.data.index,
                              data: widget.data.copyWith(
                                  namaBarang: value.first.namaBarang,
                                  price: value.first.hargajual.toInt())));
                    }
                  });
                },
                optionsBuilder: (textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  var aa =
                      await RepositoryProvider.of<BarangRepository>(context)
                          .getAll()
                          .then((value) => value
                              .map((e) => RegExp(textEditingValue.text,
                                          caseSensitive: false)
                                      .hasMatch(e.namaBarang)
                                  ? e.namaBarang
                                  : null)
                              .nonNulls
                              .toList());

                  // await RepositoryProvider.of<PengeluaranRepository>(
                  //         context)
                  //     .getNamaBarang(textEditingValue.text);
                  return aa;
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Pcs : '),
            // Text('1'),
            Flexible(
              flex: 1,
              child: DropdownButton(
                menuMaxHeight: 480,
                isDense: true,
                items: List.generate(
                    99,
                    (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        )),
                value: widget.data.pcsBarang,
                onChanged: (value) {
                  BlocProvider.of<InputserviceBloc>(context).add(
                      ChangeItemDetails(
                          idx: widget.data.index,
                          data: widget.data.copyWith(pcsBarang: value ?? 1)));
                },
              ),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  const Text('Harga per pcs : '),
                  Expanded(
                      child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      BlocProvider.of<InputserviceBloc>(context).add(
                          ChangeItemDetails(
                              idx: widget.data.index,
                              data: widget.data
                                  .copyWith(price: int.tryParse(value) ?? 0)));
                    },
                  )),
                ],
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Total Harga : '),
            Text('${widget.data.price * (widget.data.pcsBarang)}'),
          ],
        )
      ],
    );
  }
}

class ItemCardOthers extends StatelessWidget {
  final ItemCardMdl data;
  const ItemCardOthers(this.data, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Autocomplete(
              optionsBuilder: (textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return await RepositoryProvider.of<PemasukanRepository>(context)
                    .getAllLainnya(textEditingValue.text);
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) =>
                  TextField(
                focusNode: focusNode,
                onSubmitted: (value) => onFieldSubmitted,
                controller: textEditingController,
                onChanged: (value) {
                  BlocProvider.of<InputserviceBloc>(context).add(
                      ChangeItemDetails(
                          idx: data.index,
                          data: data.copyWith(namaBarang: value)));
                },
                decoration: const InputDecoration(label: Text('Nama service')),
              ),
            )),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: TextFormField(
              validator: (value) {
                if (value == null) {
                  return 'null';
                } else if (int.tryParse(value) == null) {
                  return 'not a number';
                }
                return null;
              },
              onChanged: (value) {
                if (int.tryParse(value) != null) {
                  BlocProvider.of<InputserviceBloc>(context).add(
                      ChangeItemDetails(
                          idx: data.index,
                          data: data.copyWith(price: int.tryParse(value))));
                }
              },
              decoration: const InputDecoration(label: Text('Biaya')),
            )),
          ],
        ),
      ],
    );
  }
}
