import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show LessonMenuPage;

import '../data/lesson_data.dart';
import '../providers/lesson_provider.dart';

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
