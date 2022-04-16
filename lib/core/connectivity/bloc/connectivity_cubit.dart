import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityCubit() : super(const ConnectivityState(isConnected: false)) {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((connectivity) => emitState(connectivity: connectivity));
    _connectivity
        .checkConnectivity()
        .then((connectivity) => emitState(connectivity: connectivity));
  }

  get isConnected => state.isConnected;

  @override
  Future<void> close() async {
    _connectivitySubscription.cancel();
    await super.close();
  }

  void emitState({required ConnectivityResult connectivity}) =>
      emit(copyWith(isConnected: connectivity != ConnectivityResult.none));
}
