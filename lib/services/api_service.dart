import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

class ApiService {
  // Render.com Free Tier Backend (5-Layer Forensic Engine)
  static const String baseUrl = 'https://ministry-of-truth-backend.onrender.com/api';
  
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 150),
      sendTimeout: const Duration(seconds: 150),
      headers: {
        'Connection': 'keep-alive',
        'Accept': 'application/json',
      },
    ));

    // Force HTTP/1.1 to avoid common HTTP/2 framing issues on mobile-to-cloud regional routes
    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        // Some systems might need explicit HTTP/1.1 enforcement
        return client;
      };
    }
  }

  Future<Map<String, dynamic>> analyzeMedia(XFile file) async {
    // 1. Pre-warm Pulse (Wake up the Brain)
    try {
      print('[ApiService] Sending pre-warm pulse...');
      await _dio.get('/health', options: Options(validateStatus: (status) => true));
    } catch (e) {
      print('[ApiService] Pre-warm pulse failed (ignoring): $e');
    }

    int retryCount = 0;
    const int maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        print('[ApiService] Analysis Attempt ${retryCount + 1} starting for ${file.name}...');
        
        FormData formData;
        if (kIsWeb) {
          formData = FormData.fromMap({
            'file': MultipartFile.fromBytes(
              await file.readAsBytes(),
              filename: file.name,
            ),
          });
        } else {
          formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              file.path,
              filename: file.name,
            ),
          });
        }

        final response = await _dio.post(
          '/analyze',
          data: formData,
          onSendProgress: (sent, total) {
            if (total != -1) {
              int progress = (sent / total * 100).toInt();
              print('[ApiService] Upload Progress: $progress%');
            }
          },
        );

        if (response.statusCode == 200) {
          print('[ApiService] Success! Received response.');
          return response.data;
        } else {
          print('[ApiService] Server returned error: ${response.statusCode}');
          throw Exception('Inference Engine Error (${response.statusCode})');
        }
      } catch (e, stack) {
        retryCount++;
        print('[ApiService] ERROR details: $e');
        print('[ApiService] STACK TRACE: $stack');
        
        if (retryCount > maxRetries) {
          String userMsg = 'Connection lost during analysis. This often happens on unstable mobile networks.';
          
          if (e is DioException) {
             if (e.type == DioExceptionType.connectionTimeout) userMsg = 'Connection Timeout. Please check your internet speed.';
             if (e.message?.contains('32') ?? false) userMsg = 'Broken Pipe (Error 32). The server dropped the connection. Try a smaller file or better signal.';
          }
          
          throw Exception(userMsg);
        }
        
        print('[ApiService] Waiting ${2 * retryCount}s before retry...');
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    throw Exception('Unknown Connectivity Error');
  }
}
