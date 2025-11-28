import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 信息结构来自 Last.fm album image JSON：
/// {
///   "size": "large",
///   "#text": "https://image-link.jpg"
/// }
class ImageInfo {
  final String size; // 如: small / medium / large / extralarge
  final String url;

  ImageInfo({required this.size, required this.url});

  /// 从 Last.fm JSON 安全构建 ImageInfo
  /// factory 构造函数不一定创建新对象，可以从缓存里返回已有对象，实现类似单例模式
  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    // 安全解析 size 字段 —— Last.fm 会返回小写字符串，如 "large"
    final rawSize = json['size'];
    final size = (rawSize is String) ? rawSize.trim() : '';

    // 安全解析图片 URL —— Last.fm 使用 "#text" 作为真实地址字段
    final rawUrl = json['#text'];
    final url = (rawUrl is String) ? rawUrl.trim() : '';

    return ImageInfo(size: size, url: url);
  }

  @override
  String toString() => '$size:$url';
}

class LastfmService {
  //真实的key请去 https://www.last.fm/ 官网申请
  static const String _baseUrl = 'http://ws.audioscrobbler.com/2.0/';

  //从环境变量读取 api key
  static const String apiKey = String.fromEnvironment(
    "lastfm_api_key",
    // defaultValue: "6fd88ef256bfc274dfa0797dded2bcdb",
    defaultValue: "b25b959554ed76058ac220b7b2e0a026",
  );

  LastfmService();

  Future<List<ImageInfo>> getAlbumArt(String artist, String album) async {
    final params = {
      'method': 'album.getinfo',
      'api_key': apiKey,
      'artist': artist,
      'album': album,
      'format': 'json',
    };

    try {
      final response = await _makeRequest(params);
      if (response != null && response['album'] != null) {
        final imageList = response['album']['image'] as List<dynamic>? ?? [];
        return imageList
            .map((img) => ImageInfo.fromJson(img as Map<String, dynamic>))
            .where((img) => img.url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching album art: $e');
      rethrow;
    }
    return [];
  }

  Future<List<ImageInfo>> getArtistImage(String artist) async {
    final params = <String, String>{
      'method': 'artist.getinfo',
      'api_key': apiKey,
      'artist': artist,
      'format': 'json',
    };

    // 如果你不需要特别处理异常，直接让异常往外抛就行，
    // 外层调用处去 try-catch 即可。
    final response = await _makeRequest(params);

    // 确保 response 是 Map
    if (response is! Map<String, dynamic>) {
      // 这里你可以选择抛异常，或者返回空列表，看业务需求
      // throw FormatException('Unexpected response type from Last.fm');
      return [];
    }

    final artistJson = response['artist'];
    if (artistJson is! Map<String, dynamic>) {
      return [];
    }

    final imagesJson = artistJson['image'];
    if (imagesJson is! List) {
      return [];
    }

    // whereType 保证只处理 Map<String, dynamic> 类型的元素
    return imagesJson
        .whereType<Map<String, dynamic>>()
        .map(ImageInfo.fromJson)
        .where((img) => img.url.isNotEmpty)
        .toList(growable: false);
  }

  Future<String?> getAlbumArtBySize(
      String artist,
      String album,
      String size,
      ) async {
    final images = await getAlbumArt(artist, album);
    return images
        .firstWhere(
          (img) => img.size == size,
      orElse: () => ImageInfo(size: '', url: ''),
    )
        .url
        .isEmpty
        ? null
        : images.firstWhere((img) => img.size == size).url;
  }

  /// Get artist image URL for a specific size (small, medium, large, extralarge, mega)
  Future<String?> getArtistImageBySize(String artist, String size) async {
    final images = await getArtistImage(artist);
    return images
        .firstWhere(
          (img) => img.size == size,
      orElse: () => ImageInfo(size: '', url: ''),
    )
        .url
        .isEmpty
        ? null
        : images.firstWhere((img) => img.size == size).url;
  }

  /// Get the largest available album art URL
  Future<String?> getLargestAlbumArt(String artist, String album) async {
    final images = await getAlbumArt(artist, album);
    if (images.isEmpty) return null;

    // Priority order for largest image
    const sizeOrder = ['mega', 'extralarge', 'large', 'medium', 'small'];

    for (final size in sizeOrder) {
      final image = images.firstWhere(
            (img) => img.size == size,
        orElse: () => ImageInfo(size: '', url: ''),
      );
      if (image.url.isNotEmpty) return image.url;
    }

    return images.first.url;
  }

  /// Get the largest available artist image URL
  Future<String?> getLargestArtistImage(String artist) async {
    final images = await getArtistImage(artist);
    if (images.isEmpty) return null;

    // Priority order for largest image
    const sizeOrder = ['mega', 'extralarge', 'large', 'medium', 'small'];

    for (final size in sizeOrder) {
      final image = images.firstWhere(
            (img) => img.size == size,
        orElse: () => ImageInfo(size: '', url: ''),
      );
      if (image.url.isNotEmpty) return image.url;
    }

    return images.first.url;
  }

  Future<Map<String, dynamic>?> _makeRequest(Map<String, String> params) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] != null) {
          return null;
        }

        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
