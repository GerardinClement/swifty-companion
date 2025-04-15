import 'package:flutter/material.dart';
import 'package:swifty_companion/models/tab_item.dart';
import 'package:swifty_companion/pages/profile_page.dart';
import 'package:swifty_companion/pages/search_page.dart';
import 'package:swifty_companion/services/auth_service.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:swifty_companion/layouts/bottom_navigation.dart';
import 'package:swifty_companion/pages/login_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  final AuthService authService = AuthService();
  oauth2.Client? client;
  bool isLogin = false;
  bool isLoading = true;
  static int currentTab = 0;

  late List<TabItem> tabs = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void initTabs() {
    tabs = [
      TabItem(
        tabName: "Home",
        icon: Icons.home,
        page: ProfilePage(client: client!),
        index: 0,
        key: GlobalKey<NavigatorState>(),
      ),
      TabItem(
        tabName: "Search",
        icon: Icons.search,
        page: SearchPage(client: client!),
        index: 1,
        key: GlobalKey<NavigatorState>(),
      ),
    ];
  }

  void _selectTab(int index) {
    if (index == currentTab) {
      tabs[index].key.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => currentTab = index);
    }
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      client = await authService.loadCredentials();
      if (client != null) {
        client = await authService.refreshCredentials(client!);
      }

      if (client != null) {
        initTabs();
        setState(() {
          isLogin = true;
        });
      }
    } catch (e) {
      await authService.clearCredentials();
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const App()),
              (route) => false,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onLoginSuccess(oauth2.Client newClient) {
    setState(() {
      authService.saveCredentials(newClient);
      client = newClient;
      isLogin = true;
      initTabs();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      home: isLogin
          ? _buildMainApp()
          : LoginPage(onLoginSuccess: onLoginSuccess),
    );
  }

  Widget _buildMainApp() {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(
          index: currentTab,
          children: tabs.map((e) => e.page).toList(),
        ),
        bottomNavigationBar: BottomNavigation(
          onSelectTab: _selectTab,
          tabs: tabs,
        ),
      ),
    );
  }
}
