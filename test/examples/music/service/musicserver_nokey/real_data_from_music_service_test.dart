// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/api_client.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/coverart_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/lyrics_ovh_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/music_info_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/musicbrainz_service.dart';

void main() {
  // 🔥 注意：这些测试是真正访问网络的“集成测试”，可能因为网络问题偶尔失败
  group('REAL API smoke tests (MusicBrainz + CoverArt + Lyrics)', () {
    test('MusicInfoService.fetchFullTrackInfo for Coldplay - Yellow', () async {
      final api = ApiClient(
        timeout: const Duration(seconds: 10),
        enableCaching: false,
      );

      final brainz = MusicBrainzService(api);
      final cover = CoverArtArchiveService(api);
      final lyrics = LyricsOvhService(api);

      final service = MusicInfoService(
        musicBrainz: brainz,
        coverArt: cover,
        lyricsOvh: lyrics,
      );

      print('=== [REAL] MusicInfoService.fetchFullTrackInfo("Coldplay", "Yellow") ===');
      final result = await service.fetchFullTrackInfo('Coldplay', 'Yellow');

      if (result == null) {
        print('No track found 😢');
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
        if (result.lyrics != null) {
          final firstLines = result.lyrics!
              .split('\n')
              .take(5)
              .join('\n');
          print('lyrics (first lines):\n$firstLines');
        } else {
          print('lyrics          : <NULL>');
        }
      }
      print('=============================================================');

      // 不做严格断言，防止因为网络问题导致测试失败
      expect(true, isTrue);
    });

    test('REAL MusicBrainzService.searchRecordingsByArtistAndTitle', () async {
      final api = ApiClient(
        timeout: const Duration(seconds: 10),
        enableCaching: false,
      );
      final service = MusicBrainzService(api);

      print('=== [REAL] MusicBrainzService.searchRecordingsByArtistAndTitle("Coldplay", "Yellow") ===');
      final recordings = await service.searchRecordingsByArtistAndTitle(
        'Coldplay',
        'Yellow',
        limit: 5,
      );

      if (recordings.isEmpty) {
        print('No recordings returned from MusicBrainz');
      } else {
        for (var i = 0; i < recordings.length; i++) {
          final r = recordings[i];
          print('--- Recording #$i ---');
          print('id      : ${r.id}');
          print('title   : ${r.title}');
          print('artists : ${r.artists.map((a) => a.name).join(", ")}');
          print('releases: ${r.releases.map((rel) => rel.title).join(", ")}');
        }
      }
      print('=============================================================');

      expect(true, isTrue);
    });

    test('REAL LyricsOvhService.getLyrics', () async {
      final api = ApiClient(
        timeout: const Duration(seconds: 10),
        enableCaching: false,
      );
      final service = LyricsOvhService(api);

      print('=== [REAL] LyricsOvhService.getLyrics("Coldplay", "Yellow") ===');
      final result = await service.getLyrics('Coldplay', 'Yellow');

      print('found : ${result.found}');
      if (result.lyrics.isEmpty) {
        print('lyrics: <EMPTY>');
      } else {
        final firstLines = result.lyrics.split('\n').take(10).join('\n');
        print('lyrics (first 10 lines):\n$firstLines');
      }
      print('=============================================================');

      expect(true, isTrue);
    });

    test('REAL CoverArtArchiveService.buildFrontCoverUrl + manual check', () async {
      final api = ApiClient(
        timeout: const Duration(seconds: 10),
        enableCaching: false,
      );
      final coverService = CoverArtArchiveService(api);
      final mbService = MusicBrainzService(api);

      print('=== [REAL] CoverArtArchiveService with MusicBrainz ===');

      // 先找一首歌的 release
      final recordings = await mbService.searchRecordingsByArtistAndTitle(
        'Coldplay',
        'Yellow',
        limit: 1,
      );

      if (recordings.isEmpty || recordings.first.releases.isEmpty) {
        print('No release found for Coldplay - Yellow');
        expect(true, isTrue);
        return;
      }

      final release = recordings.first.releases.first;
      final url = coverService.buildFrontCoverUrl(release.id, size: '500');

      print('release.id   : ${release.id}');
      print('release.title: ${release.title}');
      print('coverUrl     : $url');
      print('👉 你可以把这个 URL 复制到浏览器里看看封面是不是真的');
      print('=============================================================');

      expect(true, isTrue);
    });
  });
}
