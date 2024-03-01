import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_db/screens/videos_screen.dart';

// import '../models/movie.dart';
import '../models/search_category.dart';
import '../models/app_config.dart';
import '../models/main_page_data.dart';
import '../widgets/movie_tile.dart';
import '../services/http_service.dart';
import '../services/movie_service.dart';
import '../controllers/main_page_data_controller.dart';

final mainPageDataControllerProvider =
    StateNotifierProvider<MainPageDataController, MainPageData>((ref) {
  return MainPageDataController();
});

class MainScreen extends ConsumerWidget {
  static const routeName = '/main';

  final _controller = TextEditingController();
  late final MovieService _movieService;

  MainScreen({super.key});
  late MainPageData _mainPageData;
  late MainPageDataController _mainPageDataController;

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

    _movieService = MovieService();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _backgroundImage(),
          FutureBuilder(
            future: _setup(context),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );
              } else {
                _mainPageData = ref.watch(mainPageDataControllerProvider);

                _mainPageDataController =
                    ref.watch(mainPageDataControllerProvider.notifier);
                return _foregroundElements();
              }
            },
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
          child: Image.asset(
            'assets/images/placeholder_movie_image.jpg',
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
    return LayoutBuilder(
      builder: (context, constraints) {
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
                child: PagewiseListView(
                  pageSize: 20,
                  loadingBuilder: (ctx) => const Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white),
                  ),
                  noItemsFoundBuilder: (ctx) => const Center(
                    child: Text(
                      'No more movies found.',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  itemBuilder: (ctx, movie, index) {
                    return InkWell(
                      splashColor: Colors.white,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) {
                              return VideosScreen(
                                movieTitle: movie.name,
                                backdropPath: movie.backdropUrl(),
                                movieId: movie.id,
                              );
                            },
                          ),
                        );
                      },
                      child: MovieTile(
                        movie: movie,
                        screenHeight: constraints.maxHeight,
                      ),
                    );
                  },
                  pageFuture: (pageIndex) => _mainPageData.searchText.isEmpty
                      ? _movieService.getMovies(
                          page: pageIndex! + 1,
                          searchCategory: _mainPageData.searchCategory,
                        )
                      : _movieService.searchMovies(
                          searchText: _mainPageData.searchText,
                          page: pageIndex! + 1,
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchBar() {
    _controller.text = _mainPageData.searchText;
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
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _mainPageDataController.updateSearchText(value);
              }
            },
          ),
        ),
        DropdownButton(
          dropdownColor: Colors.black38,
          value: _mainPageData.searchCategory,
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
              value: SearchCategory.topRated,
              child: Text(
                SearchCategory.topRated,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            DropdownMenuItem(
              value: SearchCategory.none,
              enabled: false,
              child: Text(
                SearchCategory.none,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          onChanged: (value) {
            if (!(value == null || value == SearchCategory.none)) {
              _mainPageDataController.updateSearchCategory(value);
            }
          },
        ),
      ],
    );
  }
}
