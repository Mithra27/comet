import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/community/presentation/screens/community_feed_screen.dart';
import '../../features/items/presentation/screens/my_items_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const CommunityFeedScreen(),
    const MyItemsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'My Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: AppConstants.primaryColor,
              child: Icon(
                _selectedIndex == 0 ? Icons.search : Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                if (_selectedIndex == 0) {
                  // Navigate to search items
                } else {
                  // Navigate to add item
                }
              },
            )
          : null,
    );
  }
}