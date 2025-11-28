
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 简单的通用 API 客户端，支持：
/// - GET 请求
/// - 超时
/// - 简单内存缓存（可选）
/// - 基础错误封装
class ApiClient {
  final Duration timeout;
  final bool enableCaching;

  final Map<String, dynamic> _cache = {};

  ApiClient({
    this.timeout = const Duration(seconds: 10),
    this.enableCaching = true,
  });

  Future<Map<String, dynamic>> getJson(
      Uri uri, {
        Map<String, String>? headers,
        bool forceRefresh = false,
      }) async {
    final cacheKey = uri.toString();

    if (enableCaching && !forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    final response = await http.get(headers: headers ?? {}, uri).timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed',
        statusCode: response.statusCode,
        uri: uri,
        body: response.body,
      );
    }

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      if (enableCaching) {
        _cache[cacheKey] = data;
      }
      return data;
    } else {
      throw ApiException(
        'Response is not a JSON object',
        statusCode: response.statusCode,
        uri: uri,
        body: response.body,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Uri? uri;
  final String? body;

  ApiException(this.message, {this.statusCode, this.uri, this.body});

  @override
  String toString() {
    return 'ApiException($message, statusCode: $statusCode, uri: $uri)';
  }
}
