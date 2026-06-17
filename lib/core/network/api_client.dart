import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:happer_app/app/routes/app_routes.dart';
import 'package:happer_app/core/config/api_config.dart';
import 'package:happer_app/core/network/api_exceptions.dart';
import 'package:happer_app/core/utils/storage_service.dart';

class ApiClient {
  static const _timeout = Duration(seconds: 30);

  // ─── Logging ──────────────────────────────────────────────────────────────

  void _logRequest(String method, Uri uri,
      {Map<String, dynamic>? body, Map<String, String>? headers}) {
    if (!kDebugMode) return;
    const line = '──────────────────────────────────────────────────';
    debugPrint('┌$line');
    debugPrint('│ 🚀 $method');
    debugPrint('│ URL: $uri');
    if (headers != null && headers.isNotEmpty) {
      debugPrint('│ Headers:');
      headers.forEach((k, v) {
        final display = k == 'Authorization'
            ? '${v.substring(0, v.length.clamp(0, 20))}...'
            : v;
        debugPrint('│   $k: $display');
      });
    }
    if (body != null) {
      debugPrint('│ Body:');
      _printChunked(_prettyJson(jsonEncode(body)));
    }
    debugPrint('└$line');
  }

  void _logResponse(http.Response response, {int? durationMs}) {
    if (!kDebugMode) return;
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    final icon = ok ? '✅' : '❌';
    final timing = durationMs != null ? '  ⏱ ${durationMs}ms' : '';
    const line = '──────────────────────────────────────────────────';
    debugPrint('┌$line');
    debugPrint('│ $icon ${response.statusCode} ${response.request?.method}$timing');
    debugPrint('│ URL: ${response.request?.url}');
    debugPrint('│ Response:');
    _printChunked(_prettyJson(response.body));
    debugPrint('└$line');
  }

  /// Splits long text into 800-char chunks so debugPrint doesn't truncate.
  void _printChunked(String text) {
    const chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, text.length);
      debugPrint('│ ${text.substring(i, end)}');
    }
  }

  String _prettyJson(String raw) => raw;

  // ─── Headers ──────────────────────────────────────────────────────────────

  Map<String, String> _buildHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (requiresAuth) {
      final token = StorageService.getToken();
      if (token != null) headers['Authorization'] = token;
    }
    return headers;
  }

  // ─── HTTP Methods ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('${ApiConfig.newBaseUrl}$endpoint');
      if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
      final headers = _buildHeaders(requiresAuth: requiresAuth);
      _logRequest('GET', uri, headers: headers);
      final sw = Stopwatch()..start();
      final response =
          await http.get(uri, headers: headers).timeout(_timeout);
      sw.stop();
      return _handleResponse(response, durationMs: sw.elapsedMilliseconds);
    } on SocketException {
      throw NetworkException(
          'No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.newBaseUrl}$endpoint');
      final headers = _buildHeaders(requiresAuth: requiresAuth);
      _logRequest('POST', uri, body: body, headers: headers);
      final sw = Stopwatch()..start();
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      sw.stop();
      return _handleResponse(response, durationMs: sw.elapsedMilliseconds);
    } on SocketException {
      throw NetworkException(
          'No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.newBaseUrl}$endpoint');
      final headers = _buildHeaders(requiresAuth: requiresAuth);
      _logRequest('PUT', uri, body: body, headers: headers);
      final sw = Stopwatch()..start();
      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      sw.stop();
      return _handleResponse(response, durationMs: sw.elapsedMilliseconds);
    } on SocketException {
      throw NetworkException(
          'No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.newBaseUrl}$endpoint');
      final headers = _buildHeaders(requiresAuth: requiresAuth);
      _logRequest('DELETE', uri, body: body, headers: headers);
      final sw = Stopwatch()..start();
      final response = await http
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      sw.stop();
      return _handleResponse(response, durationMs: sw.elapsedMilliseconds);
    } on SocketException {
      throw NetworkException(
          'No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    }
  }

  Future<Map<String, dynamic>> multipart(
    String endpoint, {
    required String method,
    Map<String, String>? fields,
    Map<String, String>? filePaths,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.newBaseUrl}$endpoint');
      final request = http.MultipartRequest(method, uri);
      final headers = _buildHeaders(requiresAuth: requiresAuth)
        ..remove('Content-Type');
      request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);
      if (filePaths != null) {
        for (final entry in filePaths.entries) {
          request.files
              .add(await http.MultipartFile.fromPath(entry.key, entry.value));
        }
      }
      _logRequest(method, uri, body: fields?.cast(), headers: headers);
      final sw = Stopwatch()..start();
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      sw.stop();
      return _handleResponse(response, durationMs: sw.elapsedMilliseconds);
    } on SocketException {
      throw NetworkException(
          'No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    }
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  void _handleSessionExpired() {
    StorageService.clearAuth();
    // Delay so the exception can propagate before navigation
    Future.microtask(() {
      if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.register) {
        Get.offAllNamed(AppRoutes.register);
      }
    });
  }

  // ─── Response Handler ─────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response,
      {int? durationMs}) {
    _logResponse(response, durationMs: durationMs);
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final message =
        body['message'] as String? ?? 'Something went wrong. Please try again.';

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        _handleSessionExpired();
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 422:
        throw ValidationException(message);
      default:
        throw ServerException(message);
    }
  }
}
