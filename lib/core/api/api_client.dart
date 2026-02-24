import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: 'https://fakestoreapi.com')) {
    _dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timed out. Please try again.');
    } else if (e.type == DioExceptionType.badResponse) {
      return Exception('Received invalid response from server.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please check your network.');
    }
    return Exception('An unexpected error occurred: ${e.message}');
  }
}
