import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "https://api.intra.42.fr";
  final String? uid = dotenv.env['UID'];
  final String? secretKey = dotenv.env['SECRET_KEY'];
  final Uri redirectUrl = Uri.parse('swiftycompanion://oauth-callback');
  final Uri tokenEndpoint = Uri.parse('${dotenv.env['BASE_URL']}/oauth/token');


  final AppLinks _appLinks = AppLinks();
  oauth2.AuthorizationCodeGrant? _grant;
  StreamSubscription? _sub;

  Future<void> authenticate(Function(oauth2.Client) onSuccess, Function(dynamic error) onError) async {
    try {
      _grant = oauth2.AuthorizationCodeGrant(
        uid!,
        Uri.parse("$baseUrl/oauth/authorize"),
        tokenEndpoint,
        secret: secretKey,
      );

      final authUrl = _grant!.getAuthorizationUrl(redirectUrl);

      await _listenForRedirect(onSuccess, onError);

      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      onError(e);
    }
  }

  Future<void> refreshToken(oauth2.Client client, Function(oauth2.Client) onSuccess, Function(dynamic error) onError) async {
    try {
      final oauth2.Client newClient = await client.refreshCredentials();
      onSuccess(newClient);
    } catch (e) {
      onError(e);
    }
  }

  Future<void> _listenForRedirect(Function(oauth2.Client) onSuccess, Function(dynamic error) onError) async {
    _sub = _appLinks.uriLinkStream.listen((Uri uri) async {
      if (uri.toString().startsWith(redirectUrl.toString())) {
        _sub?.cancel();

        try {
          final client = await _grant!.handleAuthorizationResponse(uri.queryParameters);
          onSuccess(client);
        } catch (e) {
          if (e is oauth2.AuthorizationException) {
            onError(e.description);
          } else {
            onError(e.toString());
          }
        }
      }
    }, onError: (err) {
      onError(err);
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> saveCredentials(oauth2.Client client) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', client.credentials.accessToken);
    if (client.credentials.refreshToken != null) {
      await prefs.setString('refreshToken', client.credentials.refreshToken!);
    }
    if (client.credentials.expiration != null) {
      await prefs.setString('expiration', client.credentials.expiration!.toIso8601String());
    }
  }

  Future<oauth2.Client?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final expirationString = prefs.getString('expiration');
    final DateTime? expiration = expirationString != null ? DateTime.parse(expirationString) : null;

    if (accessToken != null) {
      return oauth2.Client(
        oauth2.Credentials(
            accessToken,
            refreshToken: refreshToken,
            expiration: expiration,
            tokenEndpoint: tokenEndpoint,
        ),
        identifier: uid,
        secret: secretKey,
      );
    }
    return null;
  }

  Future<oauth2.Client> refreshCredentials(oauth2.Client client) async  {
    final newClient = await client.refreshCredentials();
    await saveCredentials(newClient);
    return newClient;
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
