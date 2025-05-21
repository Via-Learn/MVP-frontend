import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vialearn_flutter/core/constants/config.dart';
import '../data/lms_oauth_service.dart';

class LMSController with ChangeNotifier {
  final LMSOAuthService _oauthService = LMSOAuthService();

  String selectedLMS = 'Canvas';
  bool isLoading = false;

  Future<void> handleReauth(BuildContext context) async {
    if (selectedLMS == 'Canvas') {
      isLoading = true;
      notifyListeners();
      try {
        final authUrl = await _oauthService.getCanvasReauthUrl("https://viaveri.instructure.com/");
        final redirectUrl = Uri.parse("https://viaveri-backend-633306289314.us-central1.run.app/canvas/oauth2/callback");

        // Listen for re-entry to the app after external OAuth
        final launched = await launchUrl(
          Uri.parse(authUrl),
          mode: LaunchMode.externalApplication,
        );

        if (!launched) throw Exception("Could not launch OAuth URL");

        // When returning from browser, the user lands back in the app.
        // You can detect this in initState of SubmitPage or trigger course loading manually.

      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
