import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userID;
  Timer _authTimer;

  bool get isAuth {
    return authToken != null;
  }

  String get authToken {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userID;
  }

  Future<void> _authenticate(
      String mEmail, String mPassword, String mURLSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$mURLSegment?key=AIzaSyBx_1SP3Hz7A0LFECebAnbpCJ5DRFyaseU';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': mEmail,
            'password': mPassword,
            'returnSecureToken': true,
          },
        ),
      );
      final responseDate = json.decode(response.body);
      print(responseDate);
      if (responseDate['error'] != null) {
        throw HTTPException(responseDate['error']['message']);
      }
      _token = responseDate['idToken'];
      _userID = responseDate['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseDate['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userID,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(String mEmail, String mPassword) async {
    return _authenticate(mEmail, mPassword, 'signUp');
  }

  Future<void> signin(String mEmail, String mPassword) async {
    return _authenticate(mEmail, mPassword, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();  
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userID = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userID = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
