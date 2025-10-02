import 'dart:async';
import 'dart:math';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dio/dio.dart';

typedef OnMessage = void Function(Map<String, dynamic>);

class WebSocketService {
  final String socketUrl; // e.g. 'https://api.example.com/chat'
  final String token;
  IO.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messagesStream => _messageController.stream;

  bool _connected = false;
  bool get connected => _connected;

  // queue messages while offline
  final List<Map<String, dynamic>> _outbox = [];

  // reconnection state
  int _retryCount = 0;
  Timer? _reconnectTimer;

  final Dio dio;

  WebSocketService({required this.socketUrl, required this.token, required this.dio});

  void connect() {
    if (_socket != null && _connected) return;

    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': token},
    });

    _socket!.on('connect', (_) {
      _connected = true;
      _retryCount = 0;
      // flush outbox
      for (var msg in _outbox) {
        _socket!.emit('send_message', msg);
      }
      _outbox.clear();
    });

    _socket!.on('disconnect', (_) {
      _connected = false;
      _scheduleReconnect();
    });

    _socket!.on('message', (data) {
      if (data is Map) _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('connect_error', (err) {
      _connected = false;
      _scheduleReconnect();
    });

    _socket!.connect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
    _retryCount++;
    final backoff = min(30, pow(2, _retryCount).toInt()); // seconds
    final jitter = Random().nextInt(3);
    final delay = Duration(seconds: backoff + jitter);
    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  void sendMessage(Map<String, dynamic> payload) {
    if (_connected && _socket != null) {
      _socket!.emit('send_message', payload);
    } else {
      // queue and fallback: also POST to REST as backup
      _outbox.add(payload);
      _fallbackPost(payload);
    }
  }

  Future<void> _fallbackPost(Map<String, dynamic> payload) async {
    try {
      await dio.post('/messages', data: payload);
    } catch (e) {
      // ignore for now; will be retried when socket reconnect flushes outbox
    }
  }

  void dispose() {
    _messageController.close();
    _socket?.disconnect();
    _socket = null;
    _reconnectTimer?.cancel();
  }
}
