import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _localAvatar;

  Future<void> _editAvatar() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _localAvatar = File(picked.path));
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _localAvatar = File(picked.path));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: _localAvatar != null
                      ? FileImage(_localAvatar!)
                      : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
                  child: (user?.photoURL == null && _localAvatar == null)
                      ? Text(
                          user?.displayName?.substring(0, 1).toUpperCase() ?? "U",
                          style: const TextStyle(fontSize: 32, color: Colors.white),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _editAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildInfoRow("Name", user?.displayName ?? 'N/A', textTheme),
            _buildInfoRow("Username", user?.email?.split('@')[0] ?? 'N/A', textTheme),
            _buildInfoRow("Email", user?.email ?? 'N/A', textTheme),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("App Theme", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            _buildThemeSelector(themeProvider),
            const SizedBox(height: 40),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    final themeMode = themeProvider.themeMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _themeCircle(themeMode == ThemeMode.light, Colors.white, () => themeProvider.setTheme(ThemeMode.light)),
        const SizedBox(width: 16),
        _themeCircle(themeMode == ThemeMode.dark, Colors.grey.shade900, () => themeProvider.setTheme(ThemeMode.dark)),
      ],
    );
  }

  Widget _themeCircle(bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: selected ? Colors.blue : Colors.grey.shade600, width: 2),
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: Colors.blue)
            : null,
      ),
    );
  }
}
