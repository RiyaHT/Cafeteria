import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as https;
import 'package:encrypt/encrypt.dart';
import 'package:splash/crypto_utils.dart';
import 'package:splash/dio_singleton.dart';

class AppState extends ChangeNotifier {
  Dio dio = DioSingleton.dio;

  var _mobileNumber;
  var _employeeNo;
  int _otp = 0;
  var _userId;
  bool _isOnline = true;
  String _accessToken = '';
  String _email = '';
  int _userBalance = 0;
  List<String> navigationHistory = [];
  IV? _iv;
  String? _base64IV;
  bool _isActive = false;

  IV? get iv => _iv;
  String? get base64IV => _base64IV;

  bool get isOnline => _isOnline;
  int get otp => _otp;
  get employeeNo => _employeeNo;
  get userId => _userId;
  get mobileNumber => _mobileNumber;
  get accessToken => _accessToken;
  get email => _email;
  get userBalance => _userBalance;
  get isActive => _isActive;

  void updateBalance(balance) {
    _userBalance = balance;
  }

  void setIsActive() {
    _isActive = true;
  }

  void updateVariables({mobileNumber, employeeNo, userId, otp, email}) {
    if (mobileNumber != null) {
      _mobileNumber = mobileNumber;
    }
    if (employeeNo != null) {
      _employeeNo = employeeNo;
    }
    if (userId != null) {
      _userId = userId;
    }
    if (otp != null) {
      _otp = otp;
      ;
    }
    if (email != null) {
      _email = email;
    }
    notifyListeners();
  }

  void updateConnectionStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }

  void addToHistory(String route) {
    navigationHistory.add(route);
  }

  getPreviousRoute() {
    if (navigationHistory.length > 1) {
      navigationHistory.removeLast();
      return navigationHistory.last;
    }
    return null;
  }

  checkStatus(String employeeNo, context) async {
    String apiLink = dotenv.env['API_LINK']!;
    print(employeeNo);
    Map<String, dynamic> postData = {
      "userEmployeeno": employeeNo,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": 'Bearer ${_accessToken}'
    };
    try {
      final response = await dio.post('${apiLink}Cafe/users/status',
          data: postData, options: Options(headers: headers));
      _isActive = true;
      print(response.data);
    } on DioException catch (err) {
      print(err.response.toString());
      if (err.response.toString() ==
              'No active users found with the given employee number.' ||
          err.response.toString() ==
              'No users found with the given employee number.') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("User is inactive!"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        _isActive = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Technical Error!"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        _isActive = false;
      }
    }
  }

  Future<void> createToken() async {
    String key = generateRandomKey();
    String iv = generateRandomIV();
    Map<String, String> jsonData = {
      "employeeId": "22775",
      "email": "Rushikesh.Salunkhe@sbigeneral.in"
    };
    String jsonString = json.encode(jsonData);
    var result = aesGcmEncryptJson(jsonString, key, iv);
    final response =
        await https.post(Uri.parse('https://cafe.sbigeneral.in/Cafe/token'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              "Accept": "application/json",
            },
            body: jsonEncode({
              "encryptedData": result,
              "key": key,
              "base64IV": iv,
            }));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      _accessToken = data['token'];
    } else {
      throw Exception('Failed to create token');
    }
  }

  void setIV(IV iv) {
    _iv = iv;
    notifyListeners();
  }

  void setBase64IV(String base64IV) {
    _base64IV = base64IV;
    notifyListeners();
  }

  void showTechnicalError(context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Technical Error!"),
        action: SnackBarAction(
          label: ' Cancel',
          onPressed: () {},
        )));
  }
}
