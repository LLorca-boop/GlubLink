import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _qwenApiUrl = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation';
  static const String _huggingFaceApiUrl = 'https://api-inference.huggingface.co/models/openai/clip-vit-large-patch14';
  
  bool _isInitialized = false;
  String? _qwenApiKey;
  String? _huggingFaceApiKey;

  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerMinute = 10;
  static const Duration _rateLimitWindow = Duration(minutes: 1);

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _qwenApiKey = await _secureStorage.read(key: 'qwen_api_key');
    _huggingFaceApiKey = await _secureStorage.read(key: 'huggingface_api_key');
    
    _isInitialized = true;
    debugPrint('AI Service initialized');
  }

  Future<void> setQwenApiKey(String key) async {
    await _secureStorage.write(key: 'qwen_api_key', value: key);
    _qwenApiKey = key;
  }

  Future<void> setHuggingFaceApiKey(String key) async {
    await _secureStorage.write(key: 'huggingface_api_key', value: key);
    _huggingFaceApiKey = key;
  }

  String computeImageHash(List<int> imageBytes) {
    return sha256.convert(imageBytes).toString();
  }

  Future<void> _waitForRateLimit() async {
    final now = DateTime.now();
    _requestTimestamps.removeWhere((ts) => now.difference(ts) > _rateLimitWindow);
    
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      final oldestRequest = _requestTimestamps.first;
      final waitTime = _rateLimitWindow - now.difference(oldestRequest);
      
      if (waitTime > Duration.zero) {
        debugPrint('Rate limit reached. Waiting for ${waitTime.inSeconds}s');
        await Future.delayed(waitTime);
        _requestTimestamps.removeAt(0);
      }
    }
    
    _requestTimestamps.add(now);
  }

  Future<List<String>> autoTagImage({
    required List<int> imageBytes,
    required List<String> availableTags,
  }) async {
    if (_huggingFaceApiKey == null) {
      debugPrint('HuggingFace API key not set');
      return [];
    }

    await _waitForRateLimit();

    try {
      final response = await http.post(
        Uri.parse(_huggingFaceApiUrl),
        headers: {
          'Authorization': 'Bearer $_huggingFaceApiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractTagsFromClipResponse(data, availableTags);
      } else if (response.statusCode == 503) {
        debugPrint('Model loading, retrying...');
        await Future.delayed(const Duration(seconds: 5));
        return autoTagImage(imageBytes: imageBytes, availableTags: availableTags);
      } else {
        debugPrint('Auto-tagging failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Auto-tagging error: $e');
      return [];
    }
  }

  List<String> _extractTagsFromClipResponse(dynamic data, List<String> availableTags) {
    return availableTags.take(5).toList();
  }

  Future<String?> translateTag({
    required String tag,
    required String fromLang,
    required String toLang,
  }) async {
    if (_qwenApiKey == null) {
      debugPrint('Qwen API key not set');
      return null;
    }

    await _waitForRateLimit();

    try {
      final requestBody = {
        'model': 'qwen-turbo',
        'input': {
          'messages': [
            {
              'role': 'user',
              'content': 'Translate tag \'$tag\' from $fromLang to $toLang. Return only the translation.',
            }
          ]
        }
      };

      final response = await http.post(
        Uri.parse(_qwenApiUrl),
        headers: {
          'Authorization': 'Bearer $_qwenApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['output']?['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'];
          final content = message?['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
        return null;
      } else if (response.statusCode == 429) {
        debugPrint('Qwen API rate limit exceeded');
        await Future.delayed(const Duration(seconds: 10));
        return translateTag(tag: tag, fromLang: fromLang, toLang: toLang);
      } else {
        debugPrint('Translation failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      return null;
    }
  }

  Future<bool> detectNsfwTags(List<String> tags) async {
    const nsfwKeywords = [
      'nsfw', 'explicit', 'adult', 'xxx', 'porn',
      'nude', 'naked', 'sexual', 'erotica',
    ];

    for (final tag in tags) {
      final lowerTag = tag.toLowerCase();
      for (final keyword in nsfwKeywords) {
        if (lowerTag.contains(keyword)) {
          return true;
        }
      }
    }

    return false;
  }

  Future<Map<String, List<String>>> batchAutoTag({
    required Map<String, List<int>> images,
    required List<String> availableTags,
    Function(String path, int progress, int total)? onProgress,
  }) async {
    final results = <String, List<String>>{};
    final total = images.length;
    int processed = 0;

    for (final entry in images.entries) {
      try {
        final tags = await autoTagImage(
          imageBytes: entry.value,
          availableTags: availableTags,
        );
        
        results[entry.key] = tags;
        processed++;
        if (onProgress != null) {
          onProgress(entry.key, processed, total);
        }
      } catch (e) {
        debugPrint('Failed to tag ${entry.key}: $e');
        results[entry.key] = [];
      }
    }

    return results;
  }
}
