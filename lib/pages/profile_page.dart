import 'package:app/api/bb_api.dart';
import 'package:app/model/profile.dart';
import 'package:app/storage/local_storage.dart';
import 'package:app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  List<String> _genres = [];
  List<String> _selectedGenres = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadProfile();
  }

  Future<void> _loadGenres() async {
    final String response =
        await rootBundle.loadString('lib/assets/data/genres.json');
    final data = await json.decode(response);
    setState(() {
      _genres = List<String>.from(data['genres']);
    });
  }

  Future<void> _loadProfile() async {
    // var profileModel = Provider.of<ProfileModel>(context, listen: false);
    var token =
        await Provider.of<LocalStorage>(context, listen: false).getToken();
    print(token);
    var userProfileData =
        await Provider.of<MyAPIService>(context, listen: false)
            .fetchProfile(token!);

    setState(() {
      _bioController.text = userProfileData['bio'] ?? '';
      _selectedGenres = userProfileData['favorite_genres'].split(',');
      // profileModel.updateBio(userProfileData['bio']);
      // profileModel.updateGenres(userProfileData['favorite_genres'].split(','));
      _statusMessage = ''; // Скидаємо статус повідомлення
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileModel>(
      builder: (context, profileModel, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('User Profile'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    onChanged: (value) {
                      profileModel.updateBio(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedGenres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        onDeleted: () {
                          setState(() {
                            profileModel.removeGenre(genre);
                            _selectedGenres.remove(genre);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    items: _genres.map((genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null &&
                          !_selectedGenres.contains(value) &&
                          _selectedGenres.length < 5) {
                        setState(() {
                          profileModel.addGenre(value);
                          _selectedGenres.add(value);
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Add Genre'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          var token = await Provider.of<LocalStorage>(context,
                                  listen: false)
                              .getToken();
                          var response = await Provider.of<MyAPIService>(
                                  context,
                                  listen: false)
                              .updateProfile(
                            token!,
                            profileModel.bio,
                            _selectedGenres.join(','),
                          );
                          if (response['bio'] != null) {
                            setState(() {
                              _statusMessage = 'Data updated successfully!';
                            });
                          }
                        },
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _loadProfile();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_statusMessage.isNotEmpty)
                    Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.green),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: const BottomNavBar());
      },
    );
  }
}
