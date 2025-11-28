import 'api_client.dart';
import 'coverart_service.dart';
import 'lyrics_ovh_service.dart';
import 'music_info_service.dart';
import 'musicbrainz_service.dart';

final ApiClient _apiClient = ApiClient();

final MusicInfoService musicInfoService = MusicInfoService(
  musicBrainz: MusicBrainzService(_apiClient),
  coverArt: CoverArtArchiveService(_apiClient),
  lyricsOvh: LyricsOvhService(_apiClient),
);
