import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/Remote/Dio_Linker.dart';
import 'package:gms_flutter/Shared/Components.dart';

import '../Modules/Login.dart';
import '../Shared/SecureStorage.dart';
import '../main.dart';
import 'End_Points.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;

  /// Use path fragments, not full URLs
  final List<String> noAuthEndpoints = [
    LOGIN,
    REFRESHTOKEN,
    FORGOTPASSWORD,
    VERIFYCODE,
    RESETFORGOTPASSWORD,
  ];

  AuthInterceptor(this.dio);

  bool _isNoAuth(RequestOptions options) {
    return noAuthEndpoints.any(
          (e) => options.path.contains(e),
    );
  }

  @override
  void onRequest(RequestOptions options,
      RequestInterceptorHandler handler,) async {
    /// ✅ DO NOT attach JWT
    if (_isNoAuth(options)) {
      handler.next(options);
      return;
    }

    final token = await TokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err,
      ErrorInterceptorHandler handler,) async {
    final req = err.requestOptions;

    /// ✅ ABSOLUTE BLOCK: no-auth APIs
    if (_isNoAuth(req)) {
      handler.next(err);
      return;
    }

    /// Only handle 401 once
    if (err.response?.statusCode != 401 ||
        req.extra['retry'] == true) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshToken();

    if (!refreshed) {
      Manager().logout();
      Future.microtask(() {
        MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Login()),
              (_) => false,
        );
      });

      ReusableComponents.showToast(
        'Your session expired. Please log in again.',
        background: Colors.red,
      );

      handler.next(err);
      return;
    }

    final newToken = await TokenStorage.readAccessToken();

    final response = await dio.request(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: Options(
        method: req.method,
        headers: {
          ...req.headers,
          'Authorization': 'Bearer $newToken',
        },
        extra: {...req.extra, 'retry': true},
      ),
    );

    handler.resolve(response);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return (await TokenStorage.readAccessToken()) != null;
    }

    _isRefreshing = true;

    try {
      final refresh = await TokenStorage.readRefreshToken();
      if (refresh == null) return false;

      final response = await Dio_Linker.postData(
        url: REFRESHTOKEN,
        data: {'refreshToken': refresh},
      );

      final access = response.data['accessToken'];
      final newRefresh = response.data['refreshToken'];

      if (access != null && newRefresh != null) {
        await TokenStorage.writeAccessToken(access);
        await TokenStorage.writeRefreshToken(newRefresh);
        return true;
      }

      return false;
    } catch (_) {
      await TokenStorage.deleteAccessToken();
      await TokenStorage.deleteRefreshToken();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
