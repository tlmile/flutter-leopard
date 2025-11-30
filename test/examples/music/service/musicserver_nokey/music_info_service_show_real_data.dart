// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/api_client.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/coverart_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/lyrics_ovh_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/music_info_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/musicbrainz_service.dart';

void main() {
  group('MusicInfoService.fetchFullTrackInfo', () {
    test('returns null when no recordings are found', () async {
      final brainz = _FakeMusicBrainzService();
      brainz.searchRecordingsResult = [];
      final cover = _FakeCoverArtArchiveService();
      final lyrics = _FakeLyricsOvhService();

      final service = MusicInfoService(
        musicBrainz: brainz,
        coverArt: cover,
        lyricsOvh: lyrics,
      );

      final result = await service.fetchFullTrackInfo('Artist', 'Title');

      // 日志：打印结果情况
      print('=== fetchFullTrackInfo: no recordings found ===');
      print('result: $result');
      print('brainz.lastArtist: ${brainz.lastArtist}');
      print('brainz.lastTitle : ${brainz.lastTitle}');
      print('cover.buildFrontCoverUrlCalls: ${cover.buildFrontCoverUrlCalls}');
      print('lyrics.requests: ${lyrics.requests}');
      print('===============================================');

      expect(result, isNull);
      expect(brainz.lastArtist, 'Artist');
      expect(brainz.lastTitle, 'Title');
      expect(cover.buildFrontCoverUrlCalls, isEmpty);
      expect(lyrics.requests, isEmpty);
    });

    test('returns assembled info with cover and lyrics', () async {
      final brainz = _FakeMusicBrainzService();
      brainz.searchRecordingsResult = [
        MusicBrainzRecording(
          id: 'recording-1',
          title: 'Yellow',
          artists: [
            MusicBrainzArtist(id: 'artist-1', name: 'Coldplay'),
          ],
          releases: [
            MusicBrainzRelease(id: 'release-1', title: 'Parachutes'),
          ],
        ),
      ];

      final cover = _FakeCoverArtArchiveService();
      cover.frontCoverUrl =
      'https://coverartarchive.org/release/release-1/front-500';

      final lyrics = _FakeLyricsOvhService()
        ..result = LyricsResult(found: true, lyrics: 'Look at the stars');

      final service = MusicInfoService(
        musicBrainz: brainz,
        coverArt: cover,
        lyricsOvh: lyrics,
      );

      final result = await service.fetchFullTrackInfo('Coldplay', 'Yellow');

      // 日志：打印组装结果的详细内容
      print('=== fetchFullTrackInfo: assembled info ===');
      if (result == null) {
        print('result is NULL');
      } else {
        print('recording.id    : ${result.recording.id}');
        print('recording.title : ${result.recording.title}');
        print(
          'artists         : ${result.recording.artists.map((a) => a.name).join(", ")}',
        );
        print(
          'releases        : ${result.recording.releases.map((r) => r.title).join(", ")}',
        );
        print('coverUrl        : ${result.coverUrl}');
        print('lyrics          : ${result.lyrics}');
      }
      print('cover.buildFrontCoverUrlCalls: ${cover.buildFrontCoverUrlCalls}');
      print('lyrics.requests              : ${lyrics.requests}');
      print('===========================================');

      expect(result, isNotNull);
      expect(result!.recording.title, 'Yellow');
      expect(result.coverUrl, cover.frontCoverUrl);
      expect(result.lyrics, 'Look at the stars');
      expect(cover.buildFrontCoverUrlCalls.single, (
      releaseMbid: 'release-1',
      size: '500',
      ));
      expect(
        lyrics.requests.single,
        (artist: 'Coldplay', title: 'Yellow'),
      );
    });

    test('falls back to provided artist when recording has no artist', () async {
      final brainz = _FakeMusicBrainzService();
      brainz.searchRecordingsResult = [
        MusicBrainzRecording(
          id: 'recording-2',
          title: 'Track',
          artists: const [],
        ),
      ];

      final cover = _FakeCoverArtArchiveService();
      final lyrics = _FakeLyricsOvhService()
        ..result = LyricsResult(found: false, lyrics: '');

      final service = MusicInfoService(
        musicBrainz: brainz,
        coverArt: cover,
        lyricsOvh: lyrics,
      );

      final result =
      await service.fetchFullTrackInfo('Fallback Artist', 'Track');

      // 日志：打印降级逻辑下的实际请求与结果
      print('=== fetchFullTrackInfo: no artist in recording ===');
      if (result == null) {
        print('result is NULL');
      } else {
        print('recording.id    : ${result.recording.id}');
        print('recording.title : ${result.recording.title}');
        print(
          'artists         : ${result.recording.artists.map((a) => a.name).join(", ")}',
        );
        print('coverUrl        : ${result.coverUrl}');
        print('lyrics          : ${result.lyrics}');
      }
      print('lyrics.requests: ${lyrics.requests}');
      print('cover.buildFrontCoverUrlCalls: ${cover.buildFrontCoverUrlCalls}');
      print('==============================================');

      expect(result, isNotNull);
      expect(result!.lyrics, isNull);
      expect(
        lyrics.requests.single,
        (artist: 'Fallback Artist', title: 'Track'),
      );
      expect(result.coverUrl, isNull);
    });
  });

  group('service url building', () {
    test('MusicBrainzService builds correct search URL', () async {
      final api = _FakeApiClient(response: {'recordings': []});
      final service = MusicBrainzService(api);

      await service.searchRecordingsByArtistAndTitle(
        'Coldplay',
        'Yellow',
        limit: 3,
      );

      // 日志：打印实际请求的 URL
      print('=== MusicBrainzService URL ===');
      print('lastUri: ${api.lastUri}');
      print('==============================');

      expect(
        api.lastUri.toString(),
        'https://musicbrainz.org/ws/2/recording'
            '?query=artist%3A%22Coldplay%22+AND+recording%3A%22Yellow%22'
            '&fmt=json&limit=3&offset=0',
      );
    });

    test('CoverArtArchiveService builds correct cover URL', () {
      final service = CoverArtArchiveService(_FakeApiClient(response: {}));

      final url = service.buildFrontCoverUrl('release-123', size: '500');

      // 日志：打印生成的 URL
      print('=== CoverArtArchiveService URL ===');
      print('url: $url');
      print('==================================');

      expect(
        url,
        'https://coverartarchive.org/release/release-123/front-500',
      );
    });

    test('LyricsOvhService hits lyrics endpoint', () async {
      final api = _FakeApiClient(response: {'lyrics': 'Fix you'});
      final service = LyricsOvhService(api);

      final result = await service.getLyrics('Coldplay', 'Yellow');

      // 日志：打印歌词结果和请求 URL
      print('=== LyricsOvhService getLyrics ===');
      print('found : ${result.found}');
      print('lyrics: "${result.lyrics}"');
      print('lastUri: ${api.lastUri}');
      print('==================================');

      expect(result.found, isTrue);
      expect(result.lyrics, 'Fix you');
      expect(
        api.lastUri.toString(),
        'https://api.lyrics.ovh/v1/Coldplay/Yellow',
      );
    });
  });
}

class _FakeMusicBrainzService implements MusicBrainzService {
  List<MusicBrainzRecording> searchRecordingsResult = const [];
  String? lastArtist;
  String? lastTitle;
  int? lastLimit;

  @override
  Future<List<MusicBrainzRecording>> searchRecordings(
      String query, {
        int limit = 5,
        int offset = 0,
      }) {
    throw UnimplementedError();
  }

  @override
  Future<List<MusicBrainzRecording>> searchRecordingsByArtistAndTitle(
      String artist,
      String title, {
        int limit = 5,
      }) async {
    lastArtist = artist;
    lastTitle = title;
    lastLimit = limit;
    return searchRecordingsResult;
  }

  @override
  Future<MusicBrainzRecording> getRecordingByMbid(String mbid) {
    throw UnimplementedError();
  }

  @override
  Future<MusicBrainzArtist> getArtistByMbid(String mbid) {
    throw UnimplementedError();
  }

  @override
  Future<MusicBrainzRelease> getReleaseByMbid(String mbid) {
    throw UnimplementedError();
  }
}

class _FakeCoverArtArchiveService implements CoverArtArchiveService {
  String? frontCoverUrl;
  final List<({String releaseMbid, String? size})> buildFrontCoverUrlCalls = [];

  @override
  Future<CoverArtReleaseImages> getReleaseImages(String releaseMbid) {
    throw UnimplementedError();
  }

  @override
  String buildFrontCoverUrl(String releaseMbid, {String? size}) {
    buildFrontCoverUrlCalls.add((releaseMbid: releaseMbid, size: size));
    return frontCoverUrl ?? '';
  }

  @override
  String buildImageUrl(String releaseMbid,
      {required String type, String? size}) {
    throw UnimplementedError();
  }
}

class _FakeLyricsOvhService implements LyricsOvhService {
  LyricsResult result = LyricsResult(found: false, lyrics: '');
  final List<({String artist, String title})> requests = [];

  @override
  Future<LyricsResult> getLyrics(String artist, String title) async {
    requests.add((artist: artist, title: title));
    return result;
  }
}

class _FakeApiClient extends ApiClient {
  final Map<String, dynamic> response;
  Uri? lastUri;

  _FakeApiClient({required this.response}) : super(enableCaching: false);

  @override
  Future<Map<String, dynamic>> getJson(
      Uri uri, {
        Map<String, String>? headers,
        bool forceRefresh = false,
      }) async {
    lastUri = uri;

    // 打印请求和返回数据，方便在测试中查看“个体数据”
    print('=== _FakeApiClient.getJson ===');
    print('URI    : $uri');
    if (headers != null && headers.isNotEmpty) {
      print('HEADERS: $headers');
    }
    print('RESPONSE: $response');
    print('================================');

    return response;
  }
}
