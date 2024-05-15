import 'package:flutter/material.dart';
import '../api/bb_api.dart';
import '../storage/local_storage.dart';

class ProfileProvider extends ChangeNotifier {
  String email = '';
  String username = '';
  int userId = 0;

  final MyAPIService apiService;
  final LocalStorage localStorage;

  ProfileProvider({required this.apiService, required this.localStorage}) {
    print('ITS WORKED_--------------');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? token = await localStorage.getToken();
    var userData = await apiService.fetchUserData(token!);
    email = userData['email'];
    username = userData['username'];
    userId = userData['user_id'];
    await localStorage.saveUserData(userId, username, email);
    notifyListeners();
  }
}
