import 'package:app/model/bottom_navbar_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavBarModel>(
      builder: (context, stateValue, child) => BottomNavigationBar(
        onTap: (value) {
          stateValue.changeIndexState(value);
          if (value == 0) {
            context.go('/home');
          } else if (value == 1) {
            context.go('/home/search');
          } else
            context.go('/home/profile');
        },
        currentIndex: stateValue.state,
        selectedItemColor: const Color.fromARGB(255, 235, 213, 149),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'SEARCH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}
