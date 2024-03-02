import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../models/app_config.dart';

class HTTPService {
  final dio = Dio();
  final getIt = GetIt.instance;

  late String _baseApiUrl;
  late String _apiKey;

  HTTPService() {
    final config = getIt.get<AppConfig>();

    _baseApiUrl = config.baseApiUrl;
    _apiKey = config.apiKey;
  }

  Future<Response?> get(String path,
      {Map<String, dynamic>? additionalQuery}) async {
    var url = '$_baseApiUrl$path';
    Response? response;
    try {
      Map<String, dynamic> query = {
        'api_key': _apiKey,
      };
      if (additionalQuery != null) {
        query.addAll(additionalQuery);
      }
      response = await dio.get(
        url,
        queryParameters: query,
      );
    } catch (error) {
      rethrow;
    }
    return response;
  }
}
