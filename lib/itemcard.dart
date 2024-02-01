import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';

import 'package:groom/model/itemcard_mdl.dart';

class ItemCard extends StatelessWidget {
  // final List<DropdownMenuEntry> entries = [
  //   DropdownMenuEntry(value: 0, label: 'Haircut'),
  //   DropdownMenuEntry(value: 1, label: 'Shave'),
  //   DropdownMenuEntry(value: 2, label: 'Semir'),
  //   DropdownMenuEntry(value: 3, label: 'Barang'),
  // ];
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
              int() => Container(
                  child: const Text('error switch'),
                )
            }
            // ItemCardHaircut()
            // Row(
            //   children: [
            //     Container(
            //       height: 124,
            //     )
            //   ],
            // )
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

class ItemCardShave extends StatelessWidget {
  final int basicPrice = 5000;
  const ItemCardShave(ItemCardMdl data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Biaya : '),
            Text('$basicPrice'),
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

class ItemCardGoods extends StatelessWidget {
  const ItemCardGoods(this.data, {super.key});
  final ItemCardMdl data;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text('Nama Barang : '),
            Expanded(child: TextField()),
          ],
        ),
        Row(
          children: [
            const Text('Pcs : '),
            // Text('1'),
            Flexible(
              child: DropdownButton(
                menuMaxHeight: 480,
                isDense: true,
                items: List.generate(
                    99,
                    (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        )),
                value: data.pcsBarang ?? 1,
                onChanged: (value) {
                  BlocProvider.of<InputserviceBloc>(context).add(
                      ChangeItemDetails(
                          idx: data.index,
                          data: data.copyWith(pcsBarang: value)));
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Text('Harga per pcs : '),
                    Expanded(
                        child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        BlocProvider.of<InputserviceBloc>(context).add(
                            ChangeItemDetails(
                                idx: data.index,
                                data: data.copyWith(price: int.parse(value))));
                      },
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Total Harga : '),
            Text('${data.price * (data.pcsBarang ?? 1)}'),
          ],
        )
      ],
    );
  }
}
