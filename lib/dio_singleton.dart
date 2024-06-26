import 'package:dio/dio.dart';

class DioSingleton {
  static var _dioInstance;

  DioSingleton._(); // private constructor to prevent instantiation

  static Dio get dio {
    if (_dioInstance == null) {
      _dioInstance = Dio(BaseOptions(responseType: ResponseType.plain));
    }
    return _dioInstance;
  }
}
