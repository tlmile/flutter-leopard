
import 'coverart_service.dart';
import 'lyrics_ovh_service.dart';
import 'musicbrainz_service.dart';

/// 音乐信息 组合接口调用


/// 组合服务示例
class MusicInfoService {
  final MusicBrainzService musicBrainz;
  final CoverArtArchiveService coverArt;
  final LyricsOvhService lyricsOvh;

  MusicInfoService({
    required this.musicBrainz,
    required this.coverArt,
    required this.lyricsOvh,
  });

  /// 综合信息：录音 + 封面 URL + 歌词
  Future<FullTrackInfo?> fetchFullTrackInfo(
      String artist,
      String title,
      ) async {
    // 1. 搜索录音
    final recordings =
    await musicBrainz.searchRecordingsByArtistAndTitle(artist, title, limit: 1);
    if (recordings.isEmpty) return null;

    final recording = recordings.first;

    // 尝试拿到 release MBID
    final release = recording.releases.isNotEmpty ? recording.releases.first : null;
    final releaseMbid = release?.id;

    // 2. 封面 URL（如果有 releaseMbid）
    String? coverUrl;
    if (releaseMbid != null) {
      coverUrl = coverArt.buildFrontCoverUrl(releaseMbid, size: '500');
    }

    // 3. 歌词
    final lyricsResult = await lyricsOvh.getLyrics(
      recording.primaryArtistName.isNotEmpty
          ? recording.primaryArtistName
          : artist,
      recording.title,
    );

    return FullTrackInfo(
      recording: recording,
      coverUrl: coverUrl,
      lyrics: lyricsResult.found ? lyricsResult.lyrics : null,
    );
  }
}

class FullTrackInfo {
  final MusicBrainzRecording recording;
  final String? coverUrl;
  final String? lyrics;

  FullTrackInfo({
    required this.recording,
    this.coverUrl,
    this.lyrics,
  });
}
