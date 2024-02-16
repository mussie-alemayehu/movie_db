import 'package:get_it/get_it.dart';

import './http_service.dart';

class MovieService {
  final getIt = GetIt.instance;
  late HTTPService http;

  MovieService() {
    http = getIt.get<HTTPService>();
  }
}
