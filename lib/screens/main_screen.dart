import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/search_category.dart';
import '../models/app_config.dart';
import '../widgets/movie_tile.dart';
import '../services/http_service.dart';
import '../services/movie_service.dart';

class MainScreen extends ConsumerWidget {
  static const routeName = '/main';
  final _controller = TextEditingController();

  MainScreen({super.key});

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
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
        future: _setup(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            );
          } else {
            return Stack(
              children: [
                _backgroundImage(),
                _foregroundElements(),
              ],
            );
          }
        },
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
            imageUrl:
                'https://image.tmdb.org/t/p/original/ovM06PdF3M8wvKb06i4sjW3xoww.jpg',
            placeholder: (ctx, url) => Image.asset(
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

  Widget _foregroundElements() {
    final List<Movie> movies = [];

    for (var i = 0; i < 10; i++) {
      movies.add(
        const Movie(
          name: 'Avatar: The Way of Water',
          language: 'EN',
          isAdult: false,
          description:
              'Set more than a decade after the events of the first film, learn '
              'the story of the Sully family (Jake, Neytiri, and their kids), '
              'the trouble that follows them, the lengths they go to keep each '
              'other safe, the battles they fight to stay alive, and the '
              'tragedies they endure.',
          posterPath: '/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
          backdropPath: '/ovM06PdF3M8wvKb06i4sjW3xoww.jpg',
          rating: 7.7,
          releaseDate: '2022-12-14',
        ),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: constraints.maxWidth * 0.08,
              right: constraints.maxWidth * 0.08,
              top: constraints.maxHeight * 0.06,
              bottom: constraints.maxHeight * 0.01,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(15),
            ),
            child: _searchBar(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: MovieTile(
                        movie: movies[index],
                        screenHeight: constraints.maxHeight,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _searchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: 'Search....',
              hintStyle: TextStyle(
                color: Colors.white54,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white38,
              ),
            ),
          ),
        ),
        DropdownButton(
          dropdownColor: Colors.black38,
          value: SearchCategory.popular,
          underline: Container(
            height: 1,
            color: Colors.white24,
          ),
          icon: const Icon(
            Icons.menu,
            color: Colors.white54,
          ),
          items: const [
            DropdownMenuItem(
              value: SearchCategory.popular,
              child: Text(
                SearchCategory.popular,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            DropdownMenuItem(
              value: SearchCategory.upcoming,
              child: Text(
                SearchCategory.upcoming,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            DropdownMenuItem(
              value: SearchCategory.none,
              child: Text(
                SearchCategory.none,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }
}
