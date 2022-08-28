import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './global_data.dart';
import '../models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiry;
  String _userId;
  Timer _authTimer;

  bool get isAuthenticated {
    return token != null;
  }

  String get token {
    if (_token != null && _expiry != null && _expiry.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signIn(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${GlobalData.firebaseApiKey}");
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        throw HttpException(responseBody['error']['message']);
      }
      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expiry = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      // start the auth timer log out when a user logins in
      _autoLogout();
      notifyListeners();
      final sharedPrefs = await SharedPreferences.getInstance();
      final userAuthData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiry': _expiry.toIso8601String(),
      });
      sharedPrefs.setString('userAuthData', userAuthData);
    } catch (error) {
      // server errors such as 422, 500, 401 will be triggered here
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${GlobalData.firebaseApiKey}");
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        throw HttpException(responseBody['error']['message']);
      }
      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expiry = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      // start the auth timer log out when a user signs in
      _autoLogout();
      notifyListeners();
      // shared_preferences works with FUTUREs
      // therefore the parent function needs to be `async`
      final sharedPrefs = await SharedPreferences.getInstance();
      // can write json to shared preferences with `json.encode()`
      // as it is always considered a string
      final userAuthData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiry': _expiry.toIso8601String(),
      });
      sharedPrefs.setString('userAuthData', userAuthData);
    } catch (error) {
      // server errors such as 422, 500, 401 will be triggered here
      throw error;
    }
  }

  // Future set as boolean as it returns a boolean rather than nothing (void)
  Future<bool> tryAutoLogin() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    if (!sharedPrefs.containsKey('userAuthData')) {
      print('LOGIN PREFS NOT FOUND');
      return false;
    }
    final userAuthData = json.decode(sharedPrefs.getString('userAuthData')) as Map<String, Object>;
    final expiry = DateTime.parse(userAuthData['expiry']);
    if (expiry.isBefore(DateTime.now())) {
      print('LOGIN EXPIRED');
      return false;
    }
    // if key present in shared prefs and not expired, update the auth data
    _token = userAuthData['token'];
    _userId = userAuthData['userId'];
    _expiry = expiry;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _expiry = null;
    // if _authTimer exists, cancel and set to null
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final sharedPrefs = await SharedPreferences.getInstance();
    // can target a specific key in shared preferences with remove()
    // sharedPrefs.remove('userAuthData');
    // or use clear() to remove all shared preference data, e.g. logout
    sharedPrefs.clear();
  }

  void _autoLogout() {
    // if an existing timer exists, cancel it
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final timeToExpiry = _expiry.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
  }
}
