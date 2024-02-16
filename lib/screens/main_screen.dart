import 'dart:convert';

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
    return Scaffold(
      body: FutureBuilder(
        future: _setup(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return const Placeholder();
          }
        },
      ),
    );
  }
}
