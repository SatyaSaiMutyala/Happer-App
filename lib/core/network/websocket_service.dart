import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  bool isConnected = false;
  Timer? _reconnectTimer;
  final int _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;
  final Duration _reconnectDelay = Duration(seconds: 2);

  // Use a StreamController to broadcast the stream to multiple listeners
  late StreamController<dynamic> _streamController;

  WebSocketService(this.url) {
    _streamController = StreamController<dynamic>.broadcast();
  }

  void connect() {
    // Don't try to connect if already connected
    if (isConnected && _channel != null) {
      debugPrint('WebSocket already connected, not reconnecting');
      return;
    }
    
    // If the stream controller was closed, recreate it
    if (_streamController.isClosed) {
      _streamController = StreamController<dynamic>.broadcast();
    }
    
    try {
      debugPrint('Connecting to WebSocket: $url');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      isConnected = true;
      _reconnectAttempts = 0; // Reset reconnect attempts on successful connection
    
      // Listen to the original stream and add events to our broadcast controller
      _channel!.stream.listen(
        (data) {
          if (!_streamController.isClosed) {
            _streamController.add(data);
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          isConnected = false;
          if (!_streamController.isClosed) {
            _streamController.addError(error);
          }
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          isConnected = false;
          // Don't close the stream controller, just schedule a reconnect
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      isConnected = false;
      
      if (!_streamController.isClosed) {
        _streamController.addError(e);
      }
      
      _scheduleReconnect();
    }
  }
  
  void _scheduleReconnect() {
    // Cancel any existing reconnect timer
    _reconnectTimer?.cancel();
    
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      debugPrint('Scheduling WebSocket reconnect attempt $_reconnectAttempts of $_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds');
      
      _reconnectTimer = Timer(_reconnectDelay, () {
        debugPrint('Attempting WebSocket reconnection...');
        connect();
      });
    } else {
      debugPrint('Maximum reconnection attempts reached');
    }
  }

  // Return the broadcast stream from the controller
  Stream<dynamic> get stream => _streamController.stream;

  void sendMessage(String message) {
    try {
      if (_channel != null && isConnected) {
        _channel!.sink.add(message);
        debugPrint('Message sent to WebSocket: $message');
      } else {
        debugPrint('Cannot send message, WebSocket not connected');
        // Try to reconnect and then send
        connect();
      }
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
    }
  }

  void disconnect() {
    try {
      _reconnectTimer?.cancel(); // Stop any pending reconnect attempts
      
      if (_channel != null) {
        debugPrint('Closing WebSocket connection');
        _channel!.sink.close();
        _channel = null;
      }
      
      isConnected = false;

      // We now keep the stream controller open for future reconnections
      // Only close it when service is being destroyed
      // if (!_streamController.isClosed) {
      //   _streamController.close();
      // }
    } catch (e) {
      debugPrint('Error disconnecting WebSocket: $e');
    }
  }
  
  // Call this method when the service is being destroyed
  void dispose() {
    disconnect();
    
    if (!_streamController.isClosed) {
      _streamController.close();
    }
  }
}
