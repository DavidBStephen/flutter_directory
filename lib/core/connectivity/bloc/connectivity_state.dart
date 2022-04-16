part of 'connectivity_cubit.dart';

class ConnectivityState {
  const ConnectivityState({required this.isConnected});

  final bool isConnected;
}

ConnectivityState copyWith({required bool isConnected}) {
  return ConnectivityState(isConnected: isConnected);
}
