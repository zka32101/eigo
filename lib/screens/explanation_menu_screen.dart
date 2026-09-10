import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show LessonMenuPage;
import '../data/lesson_data.dart';
import '../providers/lesson_provider.dart';

/// 「学ぶ（解説メニュー）」画面。
///
/// shared_core の LessonMenuPage をラップし、表示時に kLessons を
/// lessonProvider へ読み込む。
///
/// 注意: `lib/screens/lesson_screen.dart` はクイズのステージ学習画面
/// （クラス名 LessonScreen）としてすでに使われているため、
/// 本ウィジェットは別名（ExplanationMenuScreen）にしている。
class ExplanationMenuScreen extends ConsumerStatefulWidget {
  const ExplanationMenuScreen({super.key});

  @override
  ConsumerState<ExplanationMenuScreen> createState() => _ExplanationMenuScreenState();
}

class _ExplanationMenuScreenState extends ConsumerState<ExplanationMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonProvider.notifier).load(kLessons);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LessonMenuPage(lessons: kLessons);
  }
}
