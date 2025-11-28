import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/music/screen/common/todo_screen.dart';

import '../service/mpd_remote_service.dart';
import '../service/settings.dart';
import 'FavouriteTracksScreen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onFavouriteTracksTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavouriteTracksScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              // Home title
              const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Favorites section title
              const Text(
                'FAVORITES',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Favorites grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FavouriteTracksCard(
                    onTap: () => _onFavouriteTracksTap(context),
                  ),
                  // 以后要扩展更多卡片在这里加
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavouriteTracksCard extends StatelessWidget {
  final VoidCallback onTap;

  const FavouriteTracksCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(Settings.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                valueListenable: MpdRemoteService.instance.favoriteSongList,
                builder: (context, value, child) {
                  final count = (value as List).length;
                  return Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Tracks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

