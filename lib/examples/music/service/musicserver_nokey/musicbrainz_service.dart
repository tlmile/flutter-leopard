
import 'api_client.dart';

/// ======================
/// 歌曲 / 专辑 / 艺人
/// 按关键词搜索录音（recording）
// 按 artist + title 搜索录音
// 根据 recording MBID 获取详情
// 根据 artist MBID 获取艺人详情
// 根据 release / release-group MBID 获取专辑信息（配合封面用）
/// ======================

class MusicBrainzService {
  static const String _baseHost = 'musicbrainz.org';
  final ApiClient _client;

  MusicBrainzService(ApiClient client) : _client = client;

  /// 按自由文本搜索录音，如 query = "coldplay yellow"
  Future<List<MusicBrainzRecording>> searchRecordings(
      String query, {
        int limit = 5,
        int offset = 0,
      }) async {
    final uri = Uri.https(
      _baseHost,
      '/ws/2/recording',
      <String, String>{
        'query': query,
        'fmt': 'json',
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final json = await _client.getJson(uri, headers: {
      // 官方建议加上 User-Agent
      'User-Agent': 'FlutterLeopardDemo/1.0.0 ( your-email@example.com )',
    });

    final recordings = (json['recordings'] as List<dynamic>? ?? [])
        .map((e) => MusicBrainzRecording.fromJson(e as Map<String, dynamic>))
        .toList();

    return recordings;
  }

  /// 按 artist + title 搜索录音，更精确
  Future<List<MusicBrainzRecording>> searchRecordingsByArtistAndTitle(
      String artist,
      String title, {
        int limit = 5,
      }) async {
    final query = 'artist:"$artist" AND recording:"$title"';
    return searchRecordings(query, limit: limit);
  }

  /// 根据 recording MBID 获取录音详情
  Future<MusicBrainzRecording> getRecordingByMbid(String mbid) async {
    final uri = Uri.https(
      _baseHost,
      '/ws/2/recording/$mbid',
      <String, String>{
        'fmt': 'json',
        'inc': 'artist-credits+releases',
      },
    );

    final json = await _client.getJson(uri, headers: {
      'User-Agent': 'FlutterLeopardDemo/1.0.0 ( your-email@example.com )',
    });

    return MusicBrainzRecording.fromJson(json);
  }

  /// 根据 artist MBID 获取艺人详情
  Future<MusicBrainzArtist> getArtistByMbid(String mbid) async {
    final uri = Uri.https(
      _baseHost,
      '/ws/2/artist/$mbid',
      <String, String>{
        'fmt': 'json',
      },
    );

    final json = await _client.getJson(uri, headers: {
      'User-Agent': 'FlutterLeopardDemo/1.0.0 ( your-email@example.com )',
    });

    return MusicBrainzArtist.fromJson(json);
  }

  /// 根据 release MBID 获取专辑信息（可与 CoverArtArchive 搭配）
  Future<MusicBrainzRelease> getReleaseByMbid(String mbid) async {
    final uri = Uri.https(
      _baseHost,
      '/ws/2/release/$mbid',
      <String, String>{
        'fmt': 'json',
        'inc': 'recordings+artists',
      },
    );

    final json = await _client.getJson(uri, headers: {
      'User-Agent': 'FlutterLeopardDemo/1.0.0 ( your-email@example.com )',
    });

    return MusicBrainzRelease.fromJson(json);
  }
}

/// ===== MusicBrainz 基础模型（可按需要精简 / 扩展） =====

class MusicBrainzArtist {
  final String id;
  final String name;
  final String? sortName;
  final String? disambiguation;

  MusicBrainzArtist({
    required this.id,
    required this.name,
    this.sortName,
    this.disambiguation,
  });

  factory MusicBrainzArtist.fromJson(Map<String, dynamic> json) {
    return MusicBrainzArtist(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      sortName: json['sort-name'] as String?,
      disambiguation: json['disambiguation'] as String?,
    );
  }
}

class MusicBrainzRelease {
  final String id;
  final String title;
  final String? date;
  final String? country;

  MusicBrainzRelease({
    required this.id,
    required this.title,
    this.date,
    this.country,
  });

  factory MusicBrainzRelease.fromJson(Map<String, dynamic> json) {
    return MusicBrainzRelease(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      date: json['date'] as String?,
      country: json['country'] as String?,
    );
  }
}

class MusicBrainzRecording {
  final String id;
  final String title;
  final int? length; // 毫秒
  final List<MusicBrainzArtist> artists;
  final List<MusicBrainzRelease> releases;

  MusicBrainzRecording({
    required this.id,
    required this.title,
    this.length,
    this.artists = const [],
    this.releases = const [],
  });

  factory MusicBrainzRecording.fromJson(Map<String, dynamic> json) {
    final artistCredits = json['artist-credit'] as List<dynamic>? ?? [];
    final releasesJson = json['releases'] as List<dynamic>? ?? [];

    final artists = artistCredits
        .map((e) => e['artist'] as Map<String, dynamic>?)
        .where((e) => e != null)
        .map((e) => MusicBrainzArtist.fromJson(e!))
        .toList();

    final releases = releasesJson
        .map((e) => MusicBrainzRelease.fromJson(e as Map<String, dynamic>))
        .toList();

    return MusicBrainzRecording(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      length: json['length'] as int?,
      artists: artists,
      releases: releases,
    );
  }

  String get primaryArtistName =>
      artists.isNotEmpty ? artists.first.name : '';
}
