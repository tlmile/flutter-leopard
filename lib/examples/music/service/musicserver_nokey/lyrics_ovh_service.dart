import 'api_client.dart';

/// ======================
/// 根据 artist/title │ │ 返回歌词
/// ======================

class LyricsOvhService {
  static const String _baseHost = 'api.lyrics.ovh';
  final ApiClient _client;

  LyricsOvhService(ApiClient client) : _client = client;

  /// 获取歌词
  ///
  /// - 找到：返回 LyricsResult(found: true, lyrics: "...")
  /// - 未找到：found = false
  Future<LyricsResult> getLyrics(String artist, String title) async {
    // 该 API 使用纯 path 方式：/v1/{artist}/{title}
    final uri = Uri.https(
      _baseHost,
      '/v1/$artist/$title',
    );

    try {
      final json = await _client.getJson(uri);
      final lyrics = json['lyrics'] as String? ?? '';
      if (lyrics.trim().isEmpty) {
        return LyricsResult(found: false, lyrics: '');
      }
      return LyricsResult(found: true, lyrics: lyrics);
    } on ApiException catch (e) {
      // 404 时通常表示没有歌词
      if (e.statusCode == 404) {
        return LyricsResult(found: false, lyrics: '');
      }
      rethrow;
    }
  }
}

class LyricsResult {
  final bool found;
  final String lyrics;

  LyricsResult({
    required this.found,
    required this.lyrics,
  });
}
