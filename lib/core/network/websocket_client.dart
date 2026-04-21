import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';

abstract class WebSocketClientDelegate {
  void sendMessage(String message);
  void updateProducts(List<Product> products);
  void onConnectedWebSocket();
  void onFailure();
}

class WebSocketClient {
  final WebSocketService _webSocketService;
  StreamSubscription? _subscription;
  late WebSocketClientDelegate delegate;
  bool detail = false;
  List<Product> historicsOfProducts = [];
  bool _isConnected = false;

  WebSocketClient({required WebSocketService webSocketService}) 
      : _webSocketService = webSocketService {
    _initializeWebSocket();
  }

  bool get isConnected => _isConnected;

  void _initializeWebSocket() {
    debugPrint('\n====== Initializing WebSocket Client ======');
    try {
      _webSocketService.connect();
      _subscription = _webSocketService.stream.listen(
        (data) {
          if (_isConnected) {
            _handleWebSocketData(data);
          } else {
            debugPrint('WebSocket is not connected. Ignoring data.');
          }
        },
        onError: (error) {
          debugPrint('\n====== WebSocket Error Handler ======');
          debugPrint('Error: $error');
          debugPrint('==================================\n');
          _isConnected = false;
          delegate.onFailure();

          // Attempt to reconnect
          Future.delayed(Duration(seconds: 5), () {
            if (!_isConnected) {
              debugPrint('Attempting to reconnect WebSocket...');
              _initializeWebSocket();
            }
          });
        },
        onDone: () {
          debugPrint('\n====== WebSocket Connection Closed ======');
          debugPrint('Connection closed normally');
          debugPrint('======================================\n');
          _isConnected = false;

          // Attempt to reconnect
          Future.delayed(Duration(seconds: 5), () {
            if (!_isConnected) {
              debugPrint('Attempting to reconnect WebSocket...');
              _initializeWebSocket();
            }
          });
        },
      );
      _isConnected = true;
      debugPrint('WebSocket client initialized');
      debugPrint('======================================\n');
      delegate.onConnectedWebSocket();
    } catch (e) {
      debugPrint('\n====== WebSocket Initialization Error ======');
      debugPrint('Error: $e');
      debugPrint('==========================================\n');
      _isConnected = false;

      // Attempt to reconnect
      Future.delayed(Duration(seconds: 5), () {
        if (!_isConnected) {
          debugPrint('Attempting to reconnect WebSocket...');
          _initializeWebSocket();
        }
      });
    }
  }

  void disconnect() {
    debugPrint('\n====== WebSocket Disconnecting ======');
    _isConnected = false;
    _subscription?.cancel();
   
    debugPrint('WebSocket disconnected');
    debugPrint('==================================\n');
  }

  void sendMessage(String message) {
    if (!_isConnected) {
      debugPrint('\n====== WebSocket Send Error ======');
      debugPrint('Cannot send message - WebSocket not connected');
      debugPrint('Message that failed: $message');
      debugPrint('================================\n');
      return;
    }
    try {
      debugPrint('\n====== WebSocket Sending Message ======');
      debugPrint('Message: $message');
      _webSocketService.sendMessage(message);
      debugPrint('Message sent successfully');
      debugPrint('====================================\n');
    } catch (e) {
      debugPrint('\n====== WebSocket Send Error ======');
      debugPrint('Failed to send message: $e');
      debugPrint('Message that failed: $message');
      debugPrint('================================\n');
    }
  }

  void _handleWebSocketData(dynamic data) {
    try {
      debugPrint('\n====== Processing WebSocket Data ======');
      debugPrint('Raw data: $data');
      
      if (data is String) {
        try {
          final List<dynamic> message = jsonDecode(data);
          debugPrint('Parsed JSON array with ${message.length} items');
          final List<Product> products = [];
          bool pause = false;

          for (var item in message) {
            debugPrint('\nProcessing item: $item');
            if (item is Map<String, dynamic> && item.containsKey("pause")) {
              pause = item["pause"] as bool;
              debugPrint('Pause status found: $pause');
            } else if (item is Map<String, dynamic>) {
              final product = Product.fromJson(item);
              products.add(product);
              debugPrint('Added product: ${product.title} (${product.id})');
            }
          }

          debugPrint('\nTotal products processed: ${products.length}');
          for (var product in products) {
            product.pause = pause;
          }

          delegate.updateProducts(products);
          historicsOfProducts = products;
          debugPrint('Products updated successfully');
          
        } catch (e) {
          debugPrint('JSON parsing error: $e');
          debugPrint('Raw data that caused error: $data');
        }
      } else {
        debugPrint('Received non-string data: ${data.runtimeType}');
      }
      debugPrint('===================================\n');
      
    } catch (e) {
      debugPrint('\n====== WebSocket Processing Error ======');
      debugPrint('Error while processing data: $e');
      debugPrint('Data that caused error: $data');
      debugPrint('=======================================\n');
    }
  }

  void dispose() {
    debugPrint('\n====== Disposing WebSocket Client ======');
    disconnect();
    debugPrint('Successfully disposed WebSocket resources');
    debugPrint('=====================================\n');
  }
}

class Product {
  String id = "";
  String title = "";
  String description = "";
  double price = 0.0;
  String imageURL = "";
  bool pause = false;

  Product();

  Product.fromJson(Map<String, dynamic> json) {
    debugPrint('\n====== Creating Product from JSON ======');
    id = json["_id"] ?? "";
    title = json["title"] ?? "";
    description = json["description"] ?? "";
    price = (json["price"] ?? 0).toDouble();
    imageURL = json["picture_url1"] ?? "";
    
    debugPrint('Created product:');
    debugPrint('ID: $id');
    debugPrint('Title: $title');
    debugPrint('Price: $price');
    debugPrint('Image URL: $imageURL');
    debugPrint('====================================\n');
  }
}
