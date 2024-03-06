import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './tabs_screen.dart';
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
                final mainPageData = ref.watch(mainPageDataControllerProvider);

                final mainPageDataController =
                    ref.watch(mainPageDataControllerProvider.notifier);
                return _foregroundElements(
                  mainPageData: mainPageData,
                  mainPageDataController: mainPageDataController,
                );
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

  Widget _foregroundElements({
    required MainPageData mainPageData,
    required MainPageDataController mainPageDataController,
  }) {
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
              child: _searchBar(
                mainPageData: mainPageData,
                mainPageDataController: mainPageDataController,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PagewiseListView(
                  pageSize: 20,
                  showRetry: false,
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
                              return TabsScreen(
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
                  errorBuilder: (ctx, error) => const Center(
                    child: Text(
                      'There was an error.',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  pageFuture: (pageIndex) => mainPageData.searchText.isEmpty
                      ? _movieService.getMovies(
                          page: pageIndex! + 1,
                          searchCategory: mainPageData.searchCategory,
                        )
                      : _movieService.searchMovies(
                          searchText: mainPageData.searchText,
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

  Widget _searchBar({
    required MainPageData mainPageData,
    required MainPageDataController mainPageDataController,
  }) {
    _controller.text = mainPageData.searchText;
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
                mainPageDataController.updateSearchText(value);
              }
            },
          ),
        ),
        DropdownButton(
          dropdownColor: Colors.black38,
          value: mainPageData.searchCategory,
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
              mainPageDataController.updateSearchCategory(value);
            }
          },
        ),
      ],
    );
  }
}
