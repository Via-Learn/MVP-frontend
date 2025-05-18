import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/lms_oauth_service.dart';

class LMSController with ChangeNotifier {
  final LMSOAuthService _oauthService = LMSOAuthService();

  String selectedLMS = 'Canvas'; // Default
  bool isLoading = false;

  Future<void> handleReauth(BuildContext context) async {
    if (selectedLMS == 'Canvas') {
      isLoading = true;
      notifyListeners();
      try {
        final authUrl = await _oauthService.getCanvasReauthUrl("https://canvas.instructure.com");
        if (!context.mounted) return;
        await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
