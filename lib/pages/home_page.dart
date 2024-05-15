import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:app/model/bottom_navbar_state.dart';
import 'package:app/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../api/bb_api.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              FutureBuilder<String>(
                future: Provider.of<LocalStorage>(context).getUsername(),
                builder: (context, snapshot) {
                  final username = snapshot.data ?? 'Username';
                  return UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 235, 213, 149)),
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        context.go('/home/profile');
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Colors.blue),
                      ),
                    ),
                    accountName: Text(
                      username,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    accountEmail: FutureBuilder<String>(
                      future: Provider.of<LocalStorage>(context).getEmail(),
                      builder: (context, snapshot) {
                        final email = snapshot.data ?? 'Email';
                        return Text(
                          email,
                          style: const TextStyle(color: Colors.black),
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  context.go('/home/settings'); // Маршрут до налаштувань
                },
              ),
              Expanded(
                  child:
                      Container()), // Пустий простір для відсування пунктів вниз
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About Us'),
                onTap: () {
                  context.go('/about'); // Маршрут до сторінки "Про нас"
                },
              ),
              Consumer<MyAPIService>(
                builder: (context, value, child) => ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log Out'),
                  onTap: () {
                    value.logoutUser(context);
                    context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  context.go('/home/search', extra: value);
                  _controller.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Search for an artist...',
                ),
              ),
            ),
            Expanded(
              child: Center(child: Container(child: Text('Feautures'))),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar());
  }

  String getUserName() {
    String username = '';

    return username;
  }
}
