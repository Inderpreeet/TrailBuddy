import 'package:shared_preferences/shared_preferences.dart';

/// Stores simple app settings locally (no backend).
/// Currently used to save the trusted contact phone number
/// for the Safety features (Check-in / Send Help).
class SettingsRepo {
  static const String _trustedPhoneKey = 'trusted_phone';

  /// Save (or update) the trusted contact phone number.
  Future<void> setTrustedPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trustedPhoneKey, phone.trim());
  }

  /// Read the trusted contact phone number.
  /// Returns `null` if not set or empty.
  Future<String?> getTrustedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_trustedPhoneKey);
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Remove the trusted contact number (optional helper).
  Future<void> clearTrustedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trustedPhoneKey);
  }
}
