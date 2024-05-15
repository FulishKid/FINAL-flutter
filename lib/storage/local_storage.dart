import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage extends ChangeNotifier {
  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> saveUserData(int userId, String username, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId.toString());
    await prefs.setString('username', username);
    await prefs.setString('email', email);
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return int.parse(prefs.getString('user_id')!);
  }

  Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
  }
}
