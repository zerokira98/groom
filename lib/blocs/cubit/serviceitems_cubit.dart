import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:groom/db/db.dart';
import 'package:groom/model/serviceitems_mdl.dart';

part 'serviceitems_state.dart';

class ServiceitemsCubit extends Cubit<ServiceitemsState> {
  ServiceItemsRepository repo;
  ServiceitemsCubit(this.repo)
    : super( .initial);

  ///map: /{'status','details'}
  void initiate({Map<String, dynamic>? msg}) async {
    emit(state.copyWith(status: .loading));
    if (msg != null) {
      (repo.getItems(),repo.getCategories()).wait.then((value) {
      
    });
      (repo.getItems(),repo.getCategories()).wait.then((value) {
        emit(ServiceitemsState(value.$1,value.$2   , msg: msg,status: .success));
      },); 
    }
   (repo.getItems(),repo.getCategories()).wait.then((value) {
        emit(ServiceitemsState(value.$1,value.$2 ));
      },);
  }

  void clrMsg() { 
    if (state !=  .initial) {
      emit(ServiceitemsState(state.datas, state.categories));
    //  return initiate();
    }
  }

  Future<void> updateFilter() async {
    throw UnimplementedError();
    // repo.getItems().then((value) {
    //   emit(ServiceitemsState(value));
    // });
  }

  void addItem(ServiceitemsMdl serviceitemsMdl) {
    repo.addItem(serviceitemsMdl).then((value) {
      initiate(msg: {'msg':'tambah sukses'});
    });
  }
  void editItem(ServiceitemsMdl copyWith) {
    repo.editItem(copyWith).then((value) {
      initiate(msg: {'msg':'edit sukses'});
    });
  }
  void addCategory(String title) {
    repo.addCategory({'title':title.toLowerCase().trim()}).then((value) {
      initiate(msg: {'msg':'tambah sukses'});
    }).onError<Exception>((Exception error, stackTrace) {
      print('error');
      emit(state.copyWith(msg: {'msg':error},status: Status.error));
    },);
  }

  void editCategory(String title,String id) {
    repo.editCategory(title.toLowerCase().trim(),id).then((value) {
      initiate(msg: {'msg':'edit sukses'});
    });
  }

  void deleteCategory(String id) {
    repo.deleteCategory(id).then((value) {
      initiate(msg: {'msg':'delete sukses'});
    });
  }
}
