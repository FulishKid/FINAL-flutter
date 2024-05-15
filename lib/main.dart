import 'package:app/api/bb_api.dart';
import 'package:app/api/spotify_service.dart';
import 'package:app/config/go_router.dart';
import 'package:app/model/bottom_navbar_state.dart';
import 'package:app/model/profile.dart';
import 'package:app/provider/profile_provider.dart';
import 'package:app/provider/threads_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'api/spofity_acces_token.dart';
import 'model/artist.dart';
import 'model/artist_serach.dart';
import 'model/theme.dart';
import 'provider/artist_provider.dart';
import 'storage/local_storage.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => MyAPIService(),
    ),
    ChangeNotifierProvider(
      create: (context) => LocalStorage(),
    ),
    ChangeNotifierProvider(
      create: (context) => SpotifyAuth(),
    ),
    ChangeNotifierProvider(
      create: (context) => SearchModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProfileModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProfileModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => BottomNavBarModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ArtistProvider(spotifyService: SpotifyService()),
    ),
    ChangeNotifierProvider(
      create: (context) => ThreadsProvider(apiService: MyAPIService()),
    ),
    ChangeNotifierProvider(
      create: (context) => ArtistState(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProfileProvider(
          apiService: MyAPIService(), localStorage: LocalStorage()),
    ),
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GoRouter>(
      future: GoRouterConfiguration.setupRouter(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Consumer<ThemeModel>(
              builder: (context, value, child) => MaterialApp.router(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: value.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                routerConfig: snapshot.data,
              ),
            );
          } else {}
        }
        return const MaterialApp(
            home: CircularProgressIndicator(
          color: Colors.amber,
        ));
      },
    );
  }
}
