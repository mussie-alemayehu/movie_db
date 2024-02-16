import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_config.dart';
import '../services/http_service.dart';
import '../services/movie_service.dart';

class MainScreen extends ConsumerWidget {
  static const routeName = '/main';

  const MainScreen({super.key});

  Future<void> _setup(BuildContext ctx) async {
    final getIt = GetIt.instance;

    final configString = await rootBundle.loadString('assets/config/main.json');
    final configData = json.decode(configString);

    getIt.registerSingleton<AppConfig>(
      AppConfig(
        apiKey: configData['API_KEY'],
        baseApiUrl: configData['BASE_API_URL'],
        baseImageApiUrl: configData['BASE_IMAGE_API_URL'],
      ),
    );

    getIt.registerSingleton<HTTPService>(
      HTTPService(),
    );

    getIt.registerSingleton<MovieService>(
      MovieService(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder(
        future: _setup(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return SizedBox(
              height: screenSize.height,
              width: screenSize.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _backgroundImage(screenSize),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _backgroundImage(Size screenSize) {
    return Stack(
      children: [
        SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: CachedNetworkImage(
            imageUrl:
                'https://images.moviesanywhere.com/f005c2685ddb5bd690d297a64a037083/b5f8b80b-9b7e-4337-9575-c1b81579e5dc.jpg',
            placeholder: (ctx, url) => Image.asset(
              'assets/images/placeholder_movie_image.jpg',
              fit: BoxFit.cover,
            ),
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
