import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import 'cart_screen.dart';
import 'product_screen.dart';

import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Index of the Cart page inside the PageView.
  static const int _cartIndex = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ENHANCEMENT 2: Chat is no longer a bottom-navigation tab.
  // It is opened from the FloatingActionButton instead.
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ChatPlaceholderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          title: (_selectedIndex == 0)
              ? Image.asset('assets/images/app_logo.png', height: 36.h)
              : CustomText(
                  text: (_selectedIndex == _cartIndex)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                      ? 'Profile'
                      : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            ProductScreen(),
            // ENHANCEMENT 1: new Cart page rendering the /carts endpoint
            CartScreen(),
            _PlaceholderPage(icon: Icons.person, label: 'Profile coming soon'),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        // ENHANCEMENT 2: Chat as a FloatingActionButton,
        // hidden while the Cart page is showing.
        floatingActionButton: _selectedIndex == _cartIndex
            ? null
            : FloatingActionButton(
                backgroundColor: kAccent,
                foregroundColor: Colors.black87,
                tooltip: 'Chat',
                onPressed: _openChat,
                child: const Icon(Icons.chat),
              ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false, //selected item
          showUnselectedLabels: false, //unselected item
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}

/// Simple centered icon + label used for pages that are not built yet.
class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.sp, color: Colors.grey),
          SizedBox(height: 8.h),
          CustomText(text: label, fontSize: 14.sp, color: Colors.grey),
        ],
      ),
    );
  }
}

/// Temporary chat page opened by the FAB (real chat comes in Lab 6).
class _ChatPlaceholderScreen extends StatelessWidget {
  const _ChatPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Chat',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: const _PlaceholderPage(
        icon: Icons.chat_bubble_outline,
        label: 'Chat coming soon',
      ),
    );
  }
}
