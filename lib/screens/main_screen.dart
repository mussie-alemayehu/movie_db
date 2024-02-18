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

  MainScreen({super.key});
  MainPageData? _mainPageData;
  MainPageDataController? _mainPageDataController;

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
    final List<Movie> movies =
        _mainPageData == null ? [] : _mainPageData!.movies;
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
              child: movies.isEmpty
                  ? const Center(
                      child: Text(
                        'There are no movies with your current search parameters, try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
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
          value: _mainPageData == null
              ? SearchCategory.popular
              : _mainPageData!.searchCategory,
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
          ],
          onChanged: (value) =>
              (_mainPageDataController == null || value == null)
                  ? null
                  : _mainPageDataController!.updateSearchCategory(value),
        ),
      ],
    );
  }
}
