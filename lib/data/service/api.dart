import 'dart:async';
import 'dart:io';

import 'package:chatting_example/data/model/result_model.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Api {
  final String baseUrl;
  late final Dio dio;
  // const Api(this.baseUrl);

  Api(this.baseUrl) {
    // ignore: todo
    /// TODO : 토큰 추가시 여기에 맵 형식으로 넣어주자
    BaseOptions opt = BaseOptions(
        receiveTimeout: 10000,
        connectTimeout: 10000,
        baseUrl: baseUrl,
        headers: {});
    var _dio = Dio(opt)
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
            debugPrint(
                "## 쏜다! Request url:${options.baseUrl}, path:${options.path}");
            // ignore: todo
            /// TODO : 토큰 추가시 여기에 맵 형식으로 넣어주자
            Map<String, String?> header = {};

            options.headers..addAll(header);
            return handler.next(options);
          },
        ),
      );
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    this.dio = _dio;
  }

  Future<ResultModel> get(String path,
      {Map<String, String>? headerOption}) async {
    Response response =
        await dio.get(path, options: Options(headers: headerOption));
    return ResultModel.fromJson(response.data);
  }

  Future<ResultModel> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    Response response =
        await dio.post(path, data: data, queryParameters: queryParameters);
    return ResultModel.fromJson(response.data);
  }
}
