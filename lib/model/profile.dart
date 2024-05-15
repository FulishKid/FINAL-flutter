import 'package:flutter/material.dart';

class ProfileModel extends ChangeNotifier {
  String bio = '';
  List<String> favoriteGenres = [];

  void updateBio(String newBio) {
    bio = newBio;
    notifyListeners();
  }

  void updateGenres(List<String> newGenres) {
    favoriteGenres = newGenres;
    notifyListeners();
  }

  void addGenre(String genre) {
    favoriteGenres.add(genre);
    notifyListeners();
  }

  void removeGenre(String genre) {
    favoriteGenres.remove(genre);
    notifyListeners();
  }
}
