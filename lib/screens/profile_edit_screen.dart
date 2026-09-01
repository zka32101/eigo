import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final UserProfile profile;
  const ProfileEditScreen({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _nameController;
  late int _selectedGrade;
  late bool _showNameInRanking;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _selectedGrade = widget.profile.grade;
    _showNameInRanking = widget.profile.showNameInRanking;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してください')),
      );
      return;
    }

    final updated = widget.profile.copyWith(
      name: _nameController.text,
      grade: _selectedGrade,
      showNameInRanking: _showNameInRanking,
    );

    await ref.read(userProfilesProvider.notifier).updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロフィールを更新しました')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Display
            Center(
              child: Column(
                children: [
                  Text(
                    widget.profile.avatar,
                    style: const TextStyle(fontSize: 72),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    '${widget.profile.grade}年生',
                    style: AppTypography.labelLarge.copyWith(color: kTextMuted),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpacerLg,

            // Name Section
            Text(
              '名前',
              style: AppTypography.labelLarge,
            ),
            AppSpacing.verticalSpacerXs,
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '名前を入力',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
            AppSpacing.verticalSpacerLg,

            // Grade Section
            Text(
              '学年',
              style: AppTypography.labelLarge,
            ),
            AppSpacing.verticalSpacerXs,
            Row(
              children: List.generate(6, (i) {
                final grade = i + 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedGrade = grade);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedGrade == grade
                            ? kPrimaryColor
                            : Colors.grey[200],
                        foregroundColor: _selectedGrade == grade
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: Text('$grade年'),
                    ),
                  ),
                );
              }),
            ),
            AppSpacing.verticalSpacerLg,

            // Privacy Settings Section
            Container(
              padding: AppSpacing.allPaddingMd,
              decoration: BoxDecoration(
                color: kPrimaryColor.withAlpha(10),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: kPrimaryColor.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏅 ランキング設定',
                    style: AppTypography.labelLarge.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    'ランキングで名前を表示するかどうかを設定できます',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SwitchListTile(
                      secondary: Icon(
                        _showNameInRanking ? Icons.visibility : Icons.visibility_off,
                        color: _showNameInRanking ? kAccentGreen : kTextMuted,
                      ),
                      title: Text(
                        _showNameInRanking ? '名前を表示する' : '名前を表示しない',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _showNameInRanking ? kAccentGreen : kTextMuted,
                        ),
                      ),
                      subtitle: Text(
                        _showNameInRanking
                            ? 'ランキングであなたの名前が表示されます'
                            : 'ランキングで「ユーザー #XXXX」と匿名表示されます',
                        style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                      ),
                      value: _showNameInRanking,
                      onChanged: (value) {
                        setState(() {
                          _showNameInRanking = value;
                        });
                      },
                      activeThumbColor: kAccentGreen,
                      activeTrackColor: kAccentGreen.withAlpha(80),
                      contentPadding: EdgeInsets.all(AppSpacing.sm),
                    ),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Container(
                    padding: AppSpacing.allPaddingSm,
                    decoration: BoxDecoration(
                      color: kAccentOrange.withAlpha(15),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: AppSpacing.xs, top: 2),
                          child: const Icon(
                            Icons.info_outline,
                            color: kAccentOrange,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '名前を表示しない場合でも、ランキングであなたの順位や成績は常に表示されます。プライバシーを保ちながらランキング参加ができます。',
                            style: AppTypography.bodySmall.copyWith(
                              color: kTextDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpacerXl,

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('保存する'),
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('このプロフィールを削除'),
                onPressed: () => _showDeleteConfirmation(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            AppSpacing.verticalSpacerXxl,
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('プロフィールを削除'),
        content: Text(
          '「${widget.profile.name}」プロフィールを削除してもよろしいですか？'
          '\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userProfilesProvider.notifier)
                  .deleteProfile(widget.profile.id);
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プロフィールを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('削除する', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
