import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/rover_model.dart';
import 'dart:async';

final roverProvider = StateNotifierProvider<RoverNotifier, AsyncValue<Rover?>>((ref) {
  return RoverNotifier(ref);
});

class RoverNotifier extends StateNotifier<AsyncValue<Rover?>> {
  final Ref _ref;
  Timer? _timer;

  RoverNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchRoverStatus();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchRoverStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchRoverStatus() async {
    try {
      final dio = _ref.read(apiClientProvider);
      final response = await dio.get('/rover/status');
      state = AsyncValue.data(Rover.fromJson(response.data));
    } catch (e, st) {
      // If no rover found or offline, we could handle it differently
      state = AsyncValue.error(e, st);
    }
  }
}
