import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Update Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final picked = await ImagePicker().pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
              );
              if (picked != null) {
                ref.read(profileProvider.notifier).updateImage(picked.path);
              }
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) {
                ref.read(profileProvider.notifier).updateImage(picked.path);
              }
            },
            child: const Text('Choose from Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background.withOpacity(0.9),
        border: null,
        middle: Text(
          'Profile',
          style: GoogleFonts.nunito(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentYellow,
                        image: DecorationImage(
                          image: profile.localImagePath != null
                              ? FileImage(File(profile.localImagePath!)) as ImageProvider
                              : NetworkImage(profile.avatarUrl),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentYellow.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    profile.designation.isNotEmpty
                        ? '${profile.designation} ${profile.name}'
                        : profile.name,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: AppTheme.accentCyan,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${profile.currentAge > 0 ? '${profile.currentAge} years old • ' : ''}Joined ${profile.joinedAt.year}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Level & XP Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level ${profile.level}',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${profile.currentXP} / ${profile.xpForNextLevel} XP',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: profile.xpProgress,
                        backgroundColor: AppTheme.pastelSand,
                        color: AppTheme.accentYellow,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lifetime Points',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${profile.lifetimePoints}',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings Options
              _buildSettingRow(
                icon: CupertinoIcons.person_solid,
                color: AppTheme.accentYellow,
                title: 'Edit Name',
                onTap: _editNameDialog,
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                icon: CupertinoIcons.bell_solid,
                color: AppTheme.accentBrown,
                title: 'Notifications',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                icon: CupertinoIcons.lock_fill,
                color: AppTheme.accentGreen,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              Text(
                'SECURITY & PRIVACY',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                icon: CupertinoIcons.shield_fill,
                color: AppTheme.accentGreen,
                title: 'Device-Only Storage',
                onTap: () {
                  _showSecurityInfo(context);
                },
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                icon: CupertinoIcons.wifi_slash,
                color: AppTheme.accentYellow,
                title: 'Works 100% Offline',
                onTap: () {
                   _showOfflineInfo(context);
                },
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                icon: CupertinoIcons.share,
                color: AppTheme.accentCyan,
                title: 'Share App',
                onTap: () {
                  Share.share(
                    'Check out my new Routine tracker BY YBG! 🚀 Download it now to master your daily habits.',
                    subject: 'Routine tracker BY YBG',
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                icon: CupertinoIcons.info_circle_fill,
                color: AppTheme.textMuted,
                title: 'About',
                onTap: () {},
              ),

              const SizedBox(height: 80),
              Center(
                child: Text(
                  'ROUTINE TRACKER BY YBG',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMuted.withOpacity(0.5),
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(CupertinoIcons.chevron_right,
                color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _editNameDialog() {
    final profile = ref.read(profileProvider);
    _nameCtrl.text = profile.name;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Edit Name'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: CupertinoTextField(
              controller: _nameCtrl,
              autofocus: true,
              placeholder: 'Your name',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Save', style: TextStyle(color: AppTheme.accentYellow)),
              onPressed: () {
                if (_nameCtrl.text.trim().isNotEmpty) {
                  ref.read(profileProvider.notifier).updateName(_nameCtrl.text.trim());
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSecurityInfo(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Privacy First'),
        content: const Text(
          'Your data never leaves this device. We do not use cloud servers, meaning your journals and habits are 100% private to you.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Got it'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showOfflineInfo(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Offline Ready'),
        content: const Text(
          'Routine tracker BY YBG is designed to work anywhere. You don\'t need an internet connection to track your day or write your journal.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Perfect'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
