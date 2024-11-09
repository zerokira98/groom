import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/model/itemcard_mdl.dart';

class MyListTile extends StatelessWidget {
  final ItemCardMdl data;
  const MyListTile(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    var inputbloc = BlocProvider.of<InputserviceBloc>(context);
    return ListTile(
      dense: true,
      leading: Text((data.index + 1).toString()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                if (data.pcsBarang > 1) {
                  inputbloc.add(ChangeItemDetails(
                      idx: data.index,
                      data: data.copyWith(pcsBarang: data.pcsBarang - 1)));
                } else {
                  inputbloc.add(RemoveCard(data));
                }
              },
              icon: const Icon(Icons.arrow_left)),
          Text(data.pcsBarang.toString()),
          IconButton(
              onPressed: () {
                inputbloc.add(ChangeItemDetails(
                    idx: data.index,
                    data: data.copyWith(pcsBarang: data.pcsBarang + 1)));
              },
              icon: const Icon(Icons.arrow_right)),
        ],
      ),
      title: Text(cardType[data.type]),
      subtitle: Text(data.namaBarang),
    );
  }
}
