import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';
import 'dart:async';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider), ref);
});

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  
  AuthState({this.isLoading = false, this.user, this.error});
  
  AuthState copyWith({bool? isLoading, User? user, String? error, bool clearError = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final Ref _ref;

  AuthNotifier(this._dio, this._ref) : super(AuthState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        final response = await _dio.get('/profile');
        state = state.copyWith(user: User.fromJson(response.data));
      } catch (e) {
        await storage.delete(key: 'jwt_token');
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access_token'];
      await _ref.read(secureStorageProvider).write(key: 'jwt_token', value: token);
      await _loadUser();
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? e.message ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: msg.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'System error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.post('/register', data: data);
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? e.message ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: msg.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'System error: ${e.toString()}');
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStorageProvider).delete(key: 'jwt_token');
    state = AuthState();
  }
}
