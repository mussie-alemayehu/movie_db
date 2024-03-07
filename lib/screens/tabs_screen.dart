import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import './reviews_screen.dart';
import './videos_screen.dart';

class TabsScreen extends StatefulWidget {
  final String backdropPath;
  final String movieTitle;
  final int movieId;

  const TabsScreen({
    super.key,
    required this.movieTitle,
    required this.backdropPath,
    required this.movieId,
  });

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;
  late final VideosScreen _videosScreen;

  @override
  void initState() {
    super.initState();
    _videosScreen = VideosScreen(
      movieTitle: widget.movieTitle,
      movieId: widget.movieId,
    );
  }

  void _updateIndex(int value) {
    if (_currentIndex != value) {
      setState(() {
        _currentIndex = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.movieTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _updateIndex,
        backgroundColor: Colors.black,
        //  Couldn't find a way to change the color of the labels to white or
        //  something else so I decided they should not be visible altogether.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.video_collection_outlined,
              color: Colors.white,
            ),
            selectedIcon: Icon(
              Icons.video_collection,
            ),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.comment_outlined,
              color: Colors.white,
            ),
            selectedIcon: Icon(Icons.comment),
            label: 'Reviews',
          ),
        ],
      ),
      body: Stack(
        children: [
          _backgroundImage(),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.12,
            ),
            child: [
              _videosScreen,
              ReviewsScreen(widget.movieId),
            ][_currentIndex],
          ),
        ],
      ),
    );
  }

  Widget _backgroundImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CachedNetworkImage(
            imageUrl: widget.backdropPath,
            placeholder: (context, url) => Image.asset(
              'assets/images/placeholder_movie_image.jpg',
              fit: BoxFit.cover,
            ),
            fit: BoxFit.cover,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }
}
