import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/vocabulary_data.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final _tts = FlutterTts();
  String _selectedCategory = 'all';
  bool _showJapanese = false;
  int _currentIndex = 0;
  bool _isFlipped = false;
  late List<VocabWord> _filteredWords;
  DifficultyLevel? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _initTts();
    _filteredWords = allVocabWords;
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  void _updateFilter() {
    setState(() {
      var words = allVocabWords;
      if (_selectedCategory != 'all') {
        words = words.where((w) => w.category == _selectedCategory).toList();
      }
      if (_selectedDifficulty != null) {
        words = words.where((w) => w.difficulty == _selectedDifficulty).toList();
      }
      _filteredWords = words;
      _currentIndex = 0;
      _isFlipped = false;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('📖 単語カード'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showJapanese ? Icons.translate : Icons.language),
            tooltip: _showJapanese ? '英語先に表示' : '日本語先に表示',
            onPressed: () => setState(() {
              _showJapanese = !_showJapanese;
              _isFlipped = false;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            selectedCategory: _selectedCategory,
            selectedDifficulty: _selectedDifficulty,
            onCategoryChanged: (cat) {
              _selectedCategory = cat;
              _updateFilter();
            },
            onDifficultyChanged: (diff) {
              _selectedDifficulty = diff;
              _updateFilter();
            },
          ),
          if (_filteredWords.isEmpty)
            const Expanded(child: Center(child: Text('単語が見つかりません')))
          else ...[
            Padding(
              padding: AppSpacing.horizontalPaddingLg + const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_filteredWords.length}',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                  Text(
                    vocabCategories[_filteredWords[_currentIndex].category] ?? _filteredWords[_currentIndex].category,
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _filteredWords.length,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => setState(() => _isFlipped = !_isFlipped),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isFlipped
                        ? _BackCard(
                            key: const ValueKey('back'),
                            word: _filteredWords[_currentIndex],
                            showJapanese: _showJapanese,
                            onSpeak: () => _tts.speak(_filteredWords[_currentIndex].english),
                          )
                        : _FrontCard(
                            key: const ValueKey('front'),
                            word: _filteredWords[_currentIndex],
                            showJapanese: _showJapanese,
                            onSpeak: () => _tts.speak(_filteredWords[_currentIndex].english),
                          ),
                  ),
                ),
              ),
            ),
            _NavigationBar(
              currentIndex: _currentIndex,
              total: _filteredWords.length,
              onPrev: () => setState(() {
                if (_currentIndex > 0) {
                  _currentIndex--;
                  _isFlipped = false;
                }
              }),
              onNext: () => setState(() {
                if (_currentIndex < _filteredWords.length - 1) {
                  _currentIndex++;
                  _isFlipped = false;
                }
              }),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selectedCategory;
  final DifficultyLevel? selectedDifficulty;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<DifficultyLevel?> onDifficultyChanged;

  const _FilterBar({
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.onCategoryChanged,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: AppSpacing.allPaddingMd,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: 'すべて',
                  selected: selectedCategory == 'all',
                  onTap: () => onCategoryChanged('all'),
                ),
                ...vocabCategories.entries.map((e) => _CategoryChip(
                  label: e.value,
                  selected: selectedCategory == e.key,
                  onTap: () => onCategoryChanged(e.key),
                )),
              ],
            ),
          ),
          AppSpacing.verticalSpacerSm,
          Row(
            children: [
              Text('難易度: ', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
              _DiffChip(label: 'すべて', selected: selectedDifficulty == null, onTap: () => onDifficultyChanged(null)),
              _DiffChip(label: '初級', selected: selectedDifficulty == DifficultyLevel.beginner, onTap: () => onDifficultyChanged(DifficultyLevel.beginner)),
              _DiffChip(label: '中級', selected: selectedDifficulty == DifficultyLevel.intermediate, onTap: () => onDifficultyChanged(DifficultyLevel.intermediate)),
              _DiffChip(label: '上級', selected: selectedDifficulty == DifficultyLevel.advanced, onTap: () => onDifficultyChanged(DifficultyLevel.advanced)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : kTextDark,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DiffChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DiffChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? kAccentOrange : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : kTextMuted,
          ),
        ),
      ),
    );
  }
}

class _FrontCard extends StatelessWidget {
  final VocabWord word;
  final bool showJapanese;
  final VoidCallback onSpeak;
  const _FrontCard({super.key, required this.word, required this.showJapanese, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          gradient: const LinearGradient(
            colors: [kPrimaryColor, Color(0xFF5B9BD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(word.emoji, style: const TextStyle(fontSize: 72)),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    showJapanese ? word.japanese : word.english,
                    style: AppTypography.displaySmall.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!showJapanese && word.phonetic.isNotEmpty) ...[
                    AppSpacing.verticalSpacerSm,
                    Text(
                      word.phonetic,
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  AppSpacing.verticalSpacerLg,
                  Text(
                    'タップして裏を見る',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.white),
                onPressed: onSpeak,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final VocabWord word;
  final bool showJapanese;
  final VoidCallback onSpeak;
  const _BackCard({super.key, required this.word, required this.showJapanese, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(word.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  showJapanese ? word.english : word.japanese,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showJapanese && word.phonetic.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    word.phonetic,
                    style: const TextStyle(fontSize: 16, color: kTextMuted),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _diffColor(word.difficulty).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _diffLabel(word.difficulty),
                    style: TextStyle(
                      fontSize: 12,
                      color: _diffColor(word.difficulty),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: kPrimaryColor),
              onPressed: onSpeak,
            ),
          ),
        ],
      ),
    );
  }

  Color _diffColor(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:     return kAccentGreen;
      case DifficultyLevel.intermediate: return kAccentOrange;
      case DifficultyLevel.advanced:     return Colors.red;
    }
  }

  String _diffLabel(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:     return '初級';
      case DifficultyLevel.intermediate: return '中級';
      case DifficultyLevel.advanced:     return '上級';
    }
  }
}

class _NavigationBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _NavigationBar({
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentIndex > 0 ? onPrev : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('前へ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kTextMuted,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          Text(
            '${currentIndex + 1}/$total',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: currentIndex < total - 1 ? onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('次へ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
