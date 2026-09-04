import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_service_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/user_profile_card.dart';

/// User Profile Screen
/// Phase 14 Part 1: Enhanced User Profile System
class UserProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // If null, shows current user

  const UserProfileScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  late TextEditingController _bioController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final profileUserId = widget.userId ?? currentUserId;
    final isCurrentUser = profileUserId == currentUserId;

    final profileAsync = ref.watch(userProfileProvider(profileUserId));
    final editMode = ref.watch(profileEditModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider(profileUserId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(
                'User profile not found',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          _bioController.text = profile.bio ?? '';
          _titleController.text = profile.title ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  UserProfileCard(
                    profile: profile,
                    isCurrentUser: isCurrentUser,
                    onEditProfile: isCurrentUser
                        ? () {
                            ref.read(profileEditModeProvider.notifier).state = !editMode;
                          }
                        : null,
                  ),
                  AppSpacing.verticalSpacerLg,

                  // Edit Mode
                  if (editMode && isCurrentUser) ...[
                    _EditProfileSection(
                      profile: profile,
                      bioController: _bioController,
                      titleController: _titleController,
                      userId: profileUserId,
                      onSave: () {
                        // Save logic here
                        ref.read(profileEditModeProvider.notifier).state = false;
                      },
                    ),
                    AppSpacing.verticalSpacerLg,
                  ],

                  // Stats Section
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Card(
                    child: Padding(
                      padding: AppSpacing.allPaddingMd,
                      child: Column(
                        children: [
                          _StatsRow(
                            label: 'Study Time',
                            value: '${(profile.totalStudyMinutes ~/ 60)}h ${profile.totalStudyMinutes % 60}m',
                          ),
                          Divider(height: 24),
                          _StatsRow(
                            label: 'Coins Earned',
                            value: profile.coinsEarned.toString(),
                          ),
                          Divider(height: 24),
                          _StatsRow(
                            label: 'Longest Streak',
                            value: '${profile.longestStreak} days',
                          ),
                          Divider(height: 24),
                          _StatsRow(
                            label: 'Achievements',
                            value: profile.unlockedBadges.length.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.verticalSpacerLg,

                  // Privacy Settings (only for current user)
                  if (isCurrentUser) ...[
                    Text(
                      'Privacy Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalSpacerMd,
                    Card(
                      child: Padding(
                        padding: AppSpacing.allPaddingMd,
                        child: Column(
                          children: [
                            _PrivacyToggle(
                              label: 'Allow Friend Requests',
                              value: profile.allowFriendRequests,
                              onChanged: (value) {
                                // Update privacy setting
                              },
                            ),
                            Divider(height: 24),
                            _PrivacyToggle(
                              label: 'Show Online Status',
                              value: profile.showOnlineStatus,
                              onChanged: (value) {
                                // Update privacy setting
                              },
                            ),
                            Divider(height: 24),
                            _PrivacyToggle(
                              label: 'Allow Messages',
                              value: profile.allowMessages,
                              onChanged: (value) {
                                // Update privacy setting
                              },
                            ),
                            Divider(height: 24),
                            _PrivacyToggle(
                              label: 'Show Achievements',
                              value: profile.showAchievements,
                              onChanged: (value) {
                                // Update privacy setting
                              },
                            ),
                            Divider(height: 24),
                            _PrivacyToggle(
                              label: 'Show Statistics',
                              value: profile.showStatistics,
                              onChanged: (value) {
                                // Update privacy setting
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.verticalSpacerLg,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditProfileSection extends StatelessWidget {
  final UserProfile profile;
  final TextEditingController bioController;
  final TextEditingController titleController;
  final String userId;
  final VoidCallback onSave;

  const _EditProfileSection({
    required this.profile,
    required this.bioController,
    required this.titleController,
    required this.userId,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title (Optional)',
                hintText: 'e.g., English Master',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell others about yourself',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatsRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
