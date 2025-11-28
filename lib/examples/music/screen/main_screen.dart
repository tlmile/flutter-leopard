import 'package:flutter_leopard_demo/examples/music/screen/albums_screen.dart';
import 'package:flutter_leopard_demo/examples/music/screen/artists_screen.dart';
import 'package:flutter_leopard_demo/examples/music/screen/home_screen.dart';
import 'package:flutter_leopard_demo/examples/music/screen/playlists_screen.dart';
import 'package:flutter_leopard_demo/examples/music/screen/queue_screen.dart';
import 'package:flutter_leopard_demo/examples/music/screen/tracks_screen.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/bottom_island_widget.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// Hosts the bottom navigation tabs and keeps page state in sync with the
/// persistent mini-player island.
class _MainScreenState extends State<MainScreen> {
  late final PageController _pageController;
  final _currentIndexNotifier = ValueNotifier<int>(0);

  static const List<String> _tabs = [
    'HOME',
    'QUEUE',
    'TRACKS',
    'PLAYLISTS',
    'ALBUMS',
    'ARTISTS',
  ];

  static const List<Widget> _screens = [
    HomeScreen(),
    QueueScreen(),
    TracksScreen(),
    PlaylistsScreen(),
    AlbumsScreen(),
    ArtistsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndexNotifier.value == index) return;

    _currentIndexNotifier.value = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _currentIndexNotifier.value = index;
            },
            children: _screens,
          ),

          // Bottom music player island
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomIslandWidget(
              tabList: _tabs,
              currentIndexNotifier: _currentIndexNotifier,
              onTabChanged: _onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}
