import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../error/error_handler.dart';
import 'logger_service.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  
  final RxBool isConnected = false.obs;
  final RxString connectionType = 'Unknown'.obs;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _logger.info('ConnectivityService initialized');
  }
  
  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e, stackTrace) {
      await _errorHandler.handleError(e, stackTrace);
      isConnected.value = false;
      connectionType.value = 'Unknown';
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        isConnected.value = true;
        connectionType.value = 'WiFi';
        _logger.info('Connected to WiFi');
        break;
      case ConnectivityResult.mobile:
        isConnected.value = true;
        connectionType.value = 'Mobile';
        _logger.info('Connected to Mobile Data');
        break;
      case ConnectivityResult.ethernet:
        isConnected.value = true;
        connectionType.value = 'Ethernet';
        _logger.info('Connected to Ethernet');
        break;
      case ConnectivityResult.bluetooth:
        isConnected.value = true;
        connectionType.value = 'Bluetooth';
        _logger.info('Connected to Bluetooth');
        break;
      case ConnectivityResult.none:
      default:
        isConnected.value = false;
        connectionType.value = 'Offline';
        _logger.warning('No internet connection');
        break;
    }
  }
  
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return isConnected.value;
    } catch (e, stackTrace) {
      await _errorHandler.handleError(e, stackTrace);
      return false;
    }
  }
}

