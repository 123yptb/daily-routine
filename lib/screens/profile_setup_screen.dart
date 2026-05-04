import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  DateTime? _selectedDOB;
  String? _pickedImagePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty ||
        _selectedDOB == null ||
        _designationCtrl.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Info'),
          content: const Text(
              'Please fill in your name, date of birth, and designation. Image is optional.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    ref.read(profileProvider.notifier).setupProfile(
          name: _nameCtrl.text.trim(),
          dateOfBirth: _selectedDOB!,
          designation: _designationCtrl.text.trim(),
          localImagePath: _pickedImagePath,
        );

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 190,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDOB ??
                    DateTime.now().subtract(const Duration(days: 365 * 18)),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (val) => setState(() => _selectedDOB = val),
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final picked = await ImagePicker().pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
              );
              if (picked != null) setState(() => _pickedImagePath = picked.path);
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
              if (picked != null) setState(() => _pickedImagePath = picked.path);
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
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Avatar Picker ──
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentYellow.withOpacity(0.5),
                            width: 2.5,
                          ),
                          image: _pickedImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(_pickedImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: _pickedImagePath == null
                            ? const Icon(
                                CupertinoIcons.person_fill,
                                color: AppTheme.accentYellow,
                                size: 48,
                              )
                            : null,
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(CupertinoIcons.camera_fill,
                            color: Colors.white, size: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to add photo (optional)',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Title ──
                Text(
                  'Create Your Profile',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's personalize your experience.",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // ── Name ──
                _buildTextField(
                  controller: _nameCtrl,
                  placeholder: 'Full Name',
                  icon: CupertinoIcons.person_solid,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // ── DOB Picker ──
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.calendar,
                            color: AppTheme.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDOB == null
                              ? 'Date of Birth'
                              : '${_selectedDOB!.day}/${_selectedDOB!.month}/${_selectedDOB!.year}',
                          style: TextStyle(
                            color: _selectedDOB == null
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                            fontWeight: _selectedDOB == null
                                ? FontWeight.w500
                                : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Designation ──
                _buildTextField(
                  controller: _designationCtrl,
                  placeholder: 'Future Designation (e.g., Dr, CEO)',
                  icon: CupertinoIcons.briefcase_fill,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 48),

                // ── Submit ──
                GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentYellow.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text(
                            'START MY JOURNEY',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
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
      child: CupertinoTextField(
        controller: controller,
        keyboardType: keyboardType,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        placeholder: placeholder,
        placeholderStyle: const TextStyle(
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w500,
        ),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Icon(icon, color: AppTheme.textMuted, size: 20),
        ),
        decoration: null,
      ),
    );
  }
}
