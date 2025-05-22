import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class StickerApiService {
  static const String baseUrl = 'https://localhost:7064/api/sticker';

  // 創建一個忽略 SSL 證書的 HTTP 客戶端
  final http.Client _client = http.Client();

  Future<Uint8List> cropImage(dynamic file, int x, int y, int width, int height) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/crop'));
    
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: file.name,
          contentType: MediaType('image', 'png'),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'File',
          file.path,
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    request.fields.addAll({
      'X': x.toString(),
      'Y': y.toString(),
      'Width': width.toString(),
      'Height': height.toString(),
    });

    try {
      var streamedResponse = await _client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('裁剪失敗：${response.body}');
      }
    } catch (e) {
      throw Exception('請求失敗：$e');
    }
  }

  Future<Uint8List> resizeImage(dynamic file, int width, int height) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/resize'));
    
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'File',
          bytes,
          filename: file.name,
          contentType: MediaType('image', 'png'),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'File',
          file.path,
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    request.fields.addAll({
      'Width': width.toString(),
      'Height': height.toString(),
    });

    try {
      var streamedResponse = await _client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('縮放失敗：${response.body}');
      }
    } catch (e) {
      throw Exception('請求失敗：$e');
    }
  }

  void dispose() {
    _client.close();
  }
} 