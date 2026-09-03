import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';

/// Screen to select leaderboard grouping type
class LeaderboardSelectorScreen extends ConsumerWidget {
  const LeaderboardSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ランキングを選択',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _LeaderboardTypeCard(
              title: '全体ランキング',
              description: 'すべてのユーザーで競い合う',
              icon: Icons.public,
              color: Colors.blue,
              onTap: () => _navigateToLeaderboard(
                context,
                LeaderboardGroupType.overall,
              ),
            ),
            const SizedBox(height: 12),
            _LeaderboardTypeCard(
              title: '学年別ランキング',
              description: '同じ学年のユーザーと競い合う',
              icon: Icons.school,
              color: Colors.green,
              onTap: () => _showGradeSelector(context),
            ),
            const SizedBox(height: 12),
            _LeaderboardTypeCard(
              title: '開始月別ランキング',
              description: '同じ月に開始したユーザーと競い合う',
              icon: Icons.calendar_today,
              color: Colors.orange,
              onTap: () => _showMonthSelector(context),
            ),
            const SizedBox(height: 12),
            _LeaderboardTypeCard(
              title: 'グループランキング',
              description: '学年と開始月で絞ったランキング',
              icon: Icons.groups,
              color: Colors.purple,
              onTap: () => _showCombinedSelector(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLeaderboard(
    BuildContext context,
    LeaderboardGroupType groupType,
  ) {
    // TODO: Navigate to leaderboard display screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ランキングを読み込み中...')),
    );
  }

  void _showGradeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _GradeSelectorSheet(
        onGradeSelected: (grade) {
          Navigator.pop(context);
          _navigateToLeaderboard(context, LeaderboardGroupType.byGrade);
        },
      ),
    );
  }

  void _showMonthSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MonthSelectorSheet(
        onMonthSelected: (year, month) {
          Navigator.pop(context);
          _navigateToLeaderboard(context, LeaderboardGroupType.byStartMonth);
        },
      ),
    );
  }

  void _showCombinedSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CombinedSelectorSheet(
        onCombinedSelected: (grade, year, month) {
          Navigator.pop(context);
          _navigateToLeaderboard(context, LeaderboardGroupType.combined);
        },
      ),
    );
  }
}

/// Leaderboard type card
class _LeaderboardTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LeaderboardTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grade selector sheet
class _GradeSelectorSheet extends StatelessWidget {
  final Function(int) onGradeSelected;

  const _GradeSelectorSheet({required this.onGradeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学年を選択',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final grade = index + 4; // Grade 4-9
              return _GradeButton(
                grade: grade,
                onTap: () => onGradeSelected(grade),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Grade button
class _GradeButton extends StatelessWidget {
  final int grade;
  final VoidCallback onTap;

  const _GradeButton({
    required this.grade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                grade.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '年生',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Month selector sheet
class _MonthSelectorSheet extends StatelessWidget {
  final Function(int, int) onMonthSelected;

  const _MonthSelectorSheet({required this.onMonthSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '開始月を選択',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final date = DateTime(now.year, month);
              return ListTile(
                title: Text('${now.year}年${month}月'),
                onTap: () => onMonthSelected(now.year, month),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Combined selector sheet
class _CombinedSelectorSheet extends StatefulWidget {
  final Function(int, int, int) onCombinedSelected;

  const _CombinedSelectorSheet({required this.onCombinedSelected});

  @override
  State<_CombinedSelectorSheet> createState() => _CombinedSelectorSheetState();
}

class _CombinedSelectorSheetState extends State<_CombinedSelectorSheet> {
  int selectedGrade = 5;
  int selectedMonth = 1;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'グループを選択',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text('学年'),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                6,
                (index) {
                  final grade = index + 4;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('$grade年生'),
                      selected: selectedGrade == grade,
                      onSelected: (selected) {
                        setState(() => selectedGrade = grade);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('開始月'),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                12,
                (index) {
                  final month = index + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${month}月'),
                      selected: selectedMonth == month,
                      onSelected: (selected) {
                        setState(() => selectedMonth = month);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  widget.onCombinedSelected(selectedGrade, now.year, selectedMonth),
              child: const Text('確認'),
            ),
          ),
        ],
      ),
    );
  }
}
