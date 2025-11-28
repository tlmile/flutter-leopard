import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/music/service/mpd_remote_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/music_info_service.dart';
import 'package:flutter_leopard_demo/examples/music/service/musicserver_nokey/music_service_locator.dart';

class LyricsView extends StatefulWidget {
  const LyricsView({super.key});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final MusicInfoService _musicInfoService = musicInfoService;
  final ScrollController _scrollController = ScrollController();

  List<String> _lyricsLines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLyrics() async {
    try {
      final currentSong = MpdRemoteService.instance.currentSong.value;
      final artist = currentSong?.albumArtist?.first;
      final title = currentSong?.title?.first;

      if (artist == null || title == null) {
        setState(() {
          _lyricsLines = [];
          _isLoading = false;
        });
        return;
      }

      final result = await _musicInfoService.fetchFullTrackInfo(
        artist,
        title,
      );

      setState(() {
        _lyricsLines = _buildLyricsLines(result?.lyrics);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _lyricsLines = [];
        _isLoading = false;
      });
    }
  }

  List<String> _buildLyricsLines(String? lyrics) {
    if (lyrics == null) return [];

    return lyrics
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            )
          : _lyricsLines.isEmpty
              ? const Center(
                  child: Text(
                    'No lyrics available',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  itemCount: _lyricsLines.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 12,
                  ),
                  itemBuilder: (context, index) {
                    return Text(
                      _lyricsLines[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    );
                  },
                ),
    );
  }
}
