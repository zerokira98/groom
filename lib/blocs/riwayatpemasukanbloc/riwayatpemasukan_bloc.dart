import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'riwayatpemasukan_event.dart';
part 'riwayatpemasukan_state.dart';

class RiwayatpemasukanBloc extends Bloc<RiwayatpemasukanEvent, RiwayatpemasukanState> {
  RiwayatpemasukanBloc() : super(RiwayatpemasukanInitial()) {
    on<RiwayatpemasukanEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
