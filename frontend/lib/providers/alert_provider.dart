import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/alert_model.dart';
import 'dart:async';

final alertProvider = StateNotifierProvider<AlertNotifier, AsyncValue<List<Alert>>>((ref) {
  return AlertNotifier(ref);
});

class AlertNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  final Ref _ref;
  Timer? _timer;

  AlertNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchAlerts();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchAlerts());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAlerts() async {
    try {
      final dio = _ref.read(apiClientProvider);
      final response = await dio.get('/alerts');
      final List<Alert> alerts = (response.data as List).map((e) => Alert.fromJson(e)).toList();
      state = AsyncValue.data(alerts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAlertStatus(int alertId, String action) async {
    try {
      final dio = _ref.read(apiClientProvider);
      await dio.post('/alerts/$alertId/$action');
      fetchAlerts(); // Refresh list after update
    } catch (e) {
      print('Failed to $action alert: $e');
    }
  }
}
