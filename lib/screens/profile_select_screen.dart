import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class ProfileSelectScreen extends ConsumerStatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  ConsumerState<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends ConsumerState<ProfileSelectScreen> {
  final _nameController = TextEditingController();
  int _selectedGrade = 1;
  String _selectedAvatar = '👧';
  final _avatars = ['👧', '👦', '🧒', '👶', '🎀', '⚡', '🌟', '💫'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してください')),
      );
      return;
    }

    await ref.read(userProfilesProvider.notifier).addProfile(
      _nameController.text,
      _selectedGrade,
      _selectedAvatar,
    );

    // Get newly created profile ID
    final profiles = ref.read(userProfilesProvider);
    if (profiles.isNotEmpty) {
      final newProfile = profiles.last;
      await ref.read(currentUserIdProvider.notifier).setCurrentUserId(newProfile.id);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _selectProfile(UserProfile profile) async {
    await ref.read(userProfilesProvider.notifier).updateLastAccessed(profile.id);
    await ref.read(currentUserIdProvider.notifier).setCurrentUserId(profile.id);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(userProfilesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF378ADD), const Color(0xFF1E5BA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '英語コレ！',
                    style: AppTypography.headlineLarge.copyWith(color: Colors.white),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    'プロフィールを選択または作成',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Existing Profiles
            if (profiles.isNotEmpty)
              Padding(
                padding: AppSpacing.allPaddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📚 プロフィール',
                      style: AppTypography.labelLarge,
                    ),
                    AppSpacing.verticalSpacerXs,
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      children: profiles.map((profile) {
                        return GestureDetector(
                          onTap: () => _selectProfile(profile),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFDDD),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profile.avatar,
                                  style: AppTypography.headlineSmall.copyWith(fontSize: 48),
                                ),
                                AppSpacing.verticalSpacerXs,
                                Text(
                                  profile.name,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.labelLarge,
                                ),
                                AppSpacing.verticalSpacerXs,
                                Text(
                                  '${profile.grade}年生',
                                  style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                                ),
                                AppSpacing.verticalSpacerXs,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                                  ),
                                  child: Text(
                                    '💰 ${profile.coinsEarned}',
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Create New Profile Section
            Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '➕ 新しいプロフィール',
                    style: AppTypography.labelLarge,
                  ),
                  AppSpacing.verticalSpacerSm,

                  // Name Input
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
                  AppSpacing.verticalSpacerSm,

                  // Grade Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('学年を選択'),
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
                                      ? const Color(0xFF378ADD)
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
                    ],
                  ),
                  AppSpacing.verticalSpacerSm,

                  // Avatar Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('アバターを選択'),
                      AppSpacing.verticalSpacerXs,
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatars.length,
                          itemBuilder: (context, index) {
                            final avatar = _avatars[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedAvatar = avatar);
                                },
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedAvatar == avatar
                                          ? const Color(0xFF378ADD)
                                          : Colors.grey[300]!,
                                      width: _selectedAvatar == avatar ? 2 : 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                  ),
                                  child: Center(
                                    child: Text(
                                      avatar,
                                      style: AppTypography.headlineSmall.copyWith(fontSize: 32),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpacerXl,

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _createProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF378ADD),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        '作成してスタート',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
