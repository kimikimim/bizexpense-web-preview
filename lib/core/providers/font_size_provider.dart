import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeNotifier extends StateNotifier<int> {
  
  FontSizeNotifier() : super(3) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = prefs.getInt('fontSizeLevel') ?? 3;
  }

  Future<void> setFontSize(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSizeLevel', level);
    state = level;
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, int>((ref) {
  return FontSizeNotifier();
});

double getFontScale(int level) {
  switch (level) {
    case 1: return 0.85; 
    case 2: return 0.92;
    case 3: return 1.0;  
    case 4: return 1.08;
    case 5: return 1.15; 
    default: return 1.0;
  }
}
