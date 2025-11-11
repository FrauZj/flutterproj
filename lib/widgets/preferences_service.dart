
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _bestDaysKey = 'best_days_survived';

  static Future<int> getBestDaysSurvived() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestDaysKey) ?? 0;
  }

  static Future<void> setBestDaysSurvived(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestDaysKey, days);
  }

  static Future<void> updateBestDaysSurvived(int currentDays) async {
    final bestDays = await getBestDaysSurvived();
    if (currentDays > bestDays) {
      await setBestDaysSurvived(currentDays);
    }
  }
}