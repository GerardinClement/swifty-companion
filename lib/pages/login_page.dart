import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:swifty_companion/services/auth_service.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_links/app_links.dart';

class LoginPage extends StatefulWidget {
  final Function(oauth2.Client)? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService apiService = AuthService();
  late oauth2.Client client;

  @override
  void initState() {
    super.initState();
  }

  final appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void listenForRedirect(Function(Uri) onRedirect) {
    _sub = appLinks.uriLinkStream.listen((Uri uri) {
      if (uri.scheme == 'swiftycompanion') {
        onRedirect(uri);
      }
    });
  }

  void disposeRedirectListener() {
    _sub?.cancel();
  }

  dynamic _onSuccess(oauth2.Client client) {
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!(client);
    }
  }

  dynamic _onError(String error) {
    // Handle login error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _login() async {
    try {
      await apiService.authenticate(
        (client) => _onSuccess(client),
        (msg) => _onError(msg),
      );
    } catch (e) {
      // Handle any errors that occur during the authentication process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      disposeRedirectListener();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bkgrnd.jpg', fit: BoxFit.cover),
          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                child: SvgPicture.asset(
                  'assets/images/42_logo.svg',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _login,
              child: const Text('Login with OAuth2'),
            ),
          ),
        ],
      ),
    );
  }
}
