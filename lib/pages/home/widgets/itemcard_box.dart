import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groom/blocs/inputservicebloc/inputservice_bloc.dart';
import 'package:groom/model/model.dart';
import 'package:groom/model/serviceitems_mdl.dart';

class ItemCardBox extends StatelessWidget {
  final ServiceitemsMdl data;
  // final String cardTypeString;
  final Function()? ontap;
  const ItemCardBox(this.data, {this.ontap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap ??
          () {
            print('Clicked');
            // BlocProvider.of<InputserviceBloc>(context)
            //     .add(AddCard(type: cardType.indexOf(cardTypeString)));
          },
      child: Material(
        child: Tooltip(
          message: data.title,
          child: Container(
            padding: const EdgeInsets.all(4),
            height: 100,
            width: 100,
            child: Column(
              children: [
                Text(data.title, maxLines: 1),
                const Expanded(child: Center(child: Icon(Icons.abc))),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text('Rp.${data.price}'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
