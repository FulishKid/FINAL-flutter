import 'package:app/pages/auth/password_reset.dart';
import 'package:app/pages/settings_page.dart';
import 'package:app/provider/threads_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/artist_detail_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/registration_page.dart';
import '../pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/profile_page.dart';
import '../pages/serach_page.dart';
import '../pages/threads_page.dart';

class GoRouterConfiguration {
  static Future<GoRouter> setupRouter() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      print('Token: $token');

      return GoRouter(
        initialLocation: token != null ? "/home" : "/login",
        routes: [
          GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'settings',
                  name: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'profile',
                  name: 'profile',
                  builder: (context, state) => UserProfileScreen(),
                ),
                GoRoute(
                    routes: [
                      GoRoute(
                        routes: [
                          GoRoute(
                            path: 'threads',
                            name: 'threads',
                            builder: (context, state) {
                              final extras =
                                  state.extra as Map<String, String?>;
                              final String artistId = extras['artistId'] ?? '';
                              final String token = extras['token'] ?? '';
                              final String artistName =
                                  extras['artistName'] ?? '';

                              return ThreadsPage(
                                artistId: artistId,
                                token: token,
                                artistName: artistName,
                              );
                            },
                          ),
                        ],
                        path: 'artist',
                        name: 'artist',
                        builder: (context, state) {
                          final extras = state.extra as Map<String, String?>;
                          final String artistId = extras['artistId'] ?? '';
                          final String artistImgUrl =
                              extras['artistImgUrl'] ?? '';
                          final String name = extras['name'] ?? '';
                          return ArtistDetailScreen(
                              artistId: artistId,
                              artistImgUrl: artistImgUrl,
                              name: name);
                        },
                      ),
                    ],
                    path: 'search',
                    name: 'search',
                    builder: (context, state) {
                      if (state.extra is String) {
                        final String initialQuery =
                            state.extra as String? ?? '';
                        return SearchPage(initialQuery: initialQuery);
                      } else {
                        return const SearchPage(initialQuery: '');
                      }
                    }),
              ]),
          GoRoute(
              path: '/login',
              name: 'login',
              builder: (context, state) => LoginPage(),
              routes: [
                GoRoute(
                  path: 'register',
                  name: 'register',
                  builder: (context, state) => const RegistrationPage(),
                ),
                GoRoute(
                  path: 'password-reset',
                  name: 'password-reset',
                  builder: (context, state) => ResetPasswordPage(),
                ),
              ]),
        ],
      );
    } catch (e) {
      print('Error in setupRouter: $e');
      rethrow;
    }
  }
}
