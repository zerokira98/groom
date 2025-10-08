import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/etc/extension.dart';
import 'package:groom/model/model.dart';

class MyListTile extends StatelessWidget {
  final ServiceitemsMdl data;
  final int index;
  const MyListTile(this.data, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    var inputbloc = BlocProvider.of<InputserviceBloc>(context);
    return ListTile(
      // dense: true,
      leading: Text((index + 1).toString()),
      trailing: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (data.pcs > 1) {
                  inputbloc.add(
                    ChangeItemDetails(
                      idx: data.index,
                      data: data.copyWith(pcs: () => data.pcs - 1),
                    ),
                  );
                } else {
                  inputbloc.add(RemoveCard(data));
                }
              },
              icon: Icon(
                (data.pcs > 1) ? Icons.arrow_left : Icons.delete_outline,
              ),
            ),
            Text(data.pcs.toString()),
            IconButton(
              onPressed: () {
                inputbloc.add(
                  ChangeItemDetails(
                    idx: data.index,
                    data: data.copyWith(pcs: () => data.pcs + 1),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_right),
            ),
          ],
        ),
      ),
      title: Text(data.title.firstUpcase()),
      subtitle: Text((data.price * data.pcs).numberFormat(currency: true)),
    );
  }
}
