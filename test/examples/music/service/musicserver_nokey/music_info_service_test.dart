import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/music_info_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/musicbrainz_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/coverart_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/lyrics_ovh_service.dart';

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
      cover.frontCoverUrl = 'http://example.com/front-500';

      final lyrics = _FakeLyricsOvhService()
        ..result = LyricsResult(found: true, lyrics: 'Look at the stars');

      final service = MusicInfoService(
        musicBrainz: brainz,
        coverArt: cover,
        lyricsOvh: lyrics,
      );

      final result = await service.fetchFullTrackInfo('Coldplay', 'Yellow');

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

      final result = await service.fetchFullTrackInfo('Fallback Artist', 'Track');

      expect(result, isNotNull);
      expect(result!.lyrics, isNull);
      expect(
        lyrics.requests.single,
        (artist: 'Fallback Artist', title: 'Track'),
      );
      expect(result.coverUrl, isNull);
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
  String buildImageUrl(String releaseMbid, {required String type, String? size}) {
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
