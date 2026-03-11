import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:projects/utils/network/network_manager.dart';

enum ConnectivityStatus { online, offline }

@injectable
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final NetworkManager _networkManager;
  late StreamSubscription _subscription;

  ConnectivityCubit(this._networkManager) : super(ConnectivityStatus.online) {
    _checkInitialStatus();
    _subscription = _networkManager.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  Future<void> _checkInitialStatus() async {
    final connected = await _networkManager.isConnected();
    emit(connected ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      emit(ConnectivityStatus.offline);
    } else {
      emit(ConnectivityStatus.online);
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
