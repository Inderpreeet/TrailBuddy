import 'dart:io' show Platform;
import 'package:flutter/services.dart'; // for Clipboard
import 'package:url_launcher/url_launcher.dart';
import '../data/settings_repo.dart';
import 'location_service.dart';

/// Opens the native SMS app on mobile. On desktop/web, falls back to email or clipboard.
class SafetyService {
  final SettingsRepo settings;
  final LocationService location;

  SafetyService({required this.settings, required this.location});

  Future<void> sendCheckIn() async {
    await _send(
      prefix: 'I am checking in from this location:\n',
      suffix: '\n\nSent via TrailBuddy',
      emailSubject: 'TrailBuddy Check-in',
    );
  }

  Future<void> sendHelp() async {
    await _send(
      prefix: 'NEED HELP. My current location:\n',
      suffix: '\n\nSent via TrailBuddy',
      emailSubject: 'TrailBuddy – NEED HELP',
    );
  }

  Future<void> _send({
    required String prefix,
    String suffix = '',
    required String emailSubject,
  }) async {
    final phone = await settings.getTrustedPhone();
    if (phone == null) {
      throw Exception('No trusted contact set. Add one in Settings.');
    }

    final pos = await location.getCurrentPosition();
    final coords = location.coordsMessage(pos.latitude, pos.longitude);
    final body = '$prefix$coords$suffix';

    // 1) Try SMS first (works on Android/iOS)
    final smsUri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': body});
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 2) Desktop/web fallback: try email compose
    final emailUri = Uri(
      scheme: 'mailto',
      path: '', // user picks a recipient
      queryParameters: {
        'subject': emailSubject,
        'body': body,
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 3) Last resort: copy to clipboard and inform the caller
    await Clipboard.setData(ClipboardData(text: body));
    throw Exception(
      'SMS/email not supported on this platform. '
      'Message copied to clipboard — paste it into your app to send.',
    );
  }
}

