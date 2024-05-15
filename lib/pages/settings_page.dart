import 'package:app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Center(
          child: Column(
            children: [
              Consumer<ThemeModel>(
                builder: (context, themeModel, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeModel.isDarkMode,
                    onChanged: (value) {
                      themeModel.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar());
  }
}
