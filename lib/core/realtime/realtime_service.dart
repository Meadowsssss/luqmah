import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../network/api_client.dart';
import 'realtime_event.dart';

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService();
  ref.onDispose(service.dispose);
  return service;
});

class RealtimeService {
  final _events = StreamController<RealtimeEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  String? _token;
  bool _disposed = false;
  bool _shouldReconnect = false;
  int _retryAttempt = 0;

  Stream<RealtimeEvent> get events => _events.stream;

  void connect(String token) {
    if (_token == token && _channel != null) {
      return;
    }

    disconnect();
    _token = token;
    _shouldReconnect = true;
    _open();
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _retryAttempt = 0;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _events.close();
  }

  void _open() {
    final token = _token;
    if (_disposed || token == null || token.isEmpty) {
      return;
    }

    final channel = WebSocketChannel.connect(_realtimeUri());
    _channel = channel;
    channel.sink.add(jsonEncode({'type': 'auth', 'token': token}));
    _subscription = channel.stream.listen(
      _handleMessage,
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
      cancelOnError: true,
    );
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage as String) as Map<String, dynamic>;
      final event = RealtimeEvent.fromJson(decoded);
      _retryAttempt = 0;
      _events.add(event);
    } catch (_) {
      // Ignore malformed realtime messages; REST remains the source of truth.
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect ||
        _disposed ||
        _token == null ||
        _reconnectTimer != null) {
      return;
    }

    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    final seconds = _retryAttempt < 5 ? 1 << _retryAttempt : 30;
    _retryAttempt += 1;
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;
      _open();
    });
  }

  Uri _realtimeUri() {
    final baseUri = Uri.parse(ApiClient.baseUrl);
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    return baseUri.replace(scheme: scheme, path: '/realtime', query: '');
  }
}
