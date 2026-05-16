import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.method,
    this.path,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? method;
  final String? path;
  final Object? details;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  static String get _baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }
    if (kIsWeb) {
      return 'https://luqmah.meadows.lol';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'https://luqmah.meadows.lol';
      default:
        return 'https://luqmah.meadows.lol';
    }
  }

  static String get baseUrl => _baseUrl;

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    return _request(
      'GET',
      path,
      token: token,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Object? body,
  }) async {
    return _request('POST', path, token: token, body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    String? token,
    Object? body,
  }) async {
    return _request('PATCH', path, token: token, body: body);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
    Object? body,
  }) async {
    return _request('DELETE', path, token: token, body: body);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String token,
    required String fieldName,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: MediaType.parse(
            contentType ?? _contentTypeForFilename(filename),
          ),
        ),
      );

    http.Response response;
    try {
      final streamedResponse = await _client.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamedResponse);
    } on TimeoutException catch (error) {
      throw ApiException(
        'The Luqmah backend timed out. Please try again.',
        code: 'REQUEST_TIMEOUT',
        method: 'POST',
        path: path,
        details: error.toString(),
      );
    } on SocketException catch (error) {
      throw ApiException(
        'Cannot reach the Luqmah backend right now.',
        code: 'NETWORK_UNREACHABLE',
        method: 'POST',
        path: path,
        details: error.message,
      );
    }

    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode >= 400) {
      final map = decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
      throw ApiException(
        map['message'] as String? ?? 'Upload failed',
        statusCode: response.statusCode,
        code: map['code'] as String?,
        method: 'POST',
        path: path,
        details: map['details'] ?? map['errors'] ?? map['debug'],
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        'Unexpected response format',
        code: 'INVALID_RESPONSE_FORMAT',
      );
    }

    return decoded;
  }

  String _contentTypeForFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    String? token,
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParameters);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        default:
          throw UnsupportedError('Unsupported method $method');
      }
    } on TimeoutException catch (error) {
      throw ApiException(
        'The Luqmah backend timed out. Please try again.',
        code: 'REQUEST_TIMEOUT',
        method: method,
        path: path,
        details: error.toString(),
      );
    } on SocketException catch (error) {
      throw ApiException(
        'Cannot reach the Luqmah backend right now.',
        code: 'NETWORK_UNREACHABLE',
        method: method,
        path: path,
        details: error.message,
      );
    }

    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode >= 400) {
      final map = decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
      throw ApiException(
        map['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
        code: map['code'] as String?,
        method: method,
        path: path,
        details: map['details'] ?? map['errors'] ?? map['debug'],
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        'Unexpected response format',
        code: 'INVALID_RESPONSE_FORMAT',
      );
    }

    return decoded;
  }
}
