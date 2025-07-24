// ignore_for_file: unused_import

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tixly/core/theme/blur_app_bar.dart';
import 'package:tixly/core/theme/theme_mode_provider.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;
import 'package:tixly/features/profile/data/providers/profile_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  // ignore: unused_field
  File? _picked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
      context.read<ProfileProvider>().loadProfile(uid).then((_) {
        final profile = context.read<ProfileProvider>().profile;
        if (profile != null) {
          _nameCtrl.text = profile.displayName;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    final profile = prov.profile;
    final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
    final themeModeProvider = context.watch<ThemeModeProvider>();
    final isDark = themeModeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: BlurAppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<app.AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF499F68)
            : const Color(0xFF623CEA),
      ),
      body: prov.isLoading || profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final xf = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (xf != null) {
                        try {
                          await prov.setAvatar(File(xf.path));
                          // Aggiorna anche la UI se serve
                        } catch (e) {}
                      }
                    },
                    child: profile.profileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: profile.profileImageUrl!,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 50,
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) => const CircleAvatar(
                              radius: 50,
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 50,
                              child: Text(
                                profile.displayName[0].toUpperCase(),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 50,
                            child: Text(
                              profile.displayName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl..text = profile.displayName,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await prov.setDisplayName(_nameCtrl.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Modifiche Effettuate!'),
                          ),
                        );
                      } catch (e) {
                        // debugPrint('Errore: $e'); // RIMOSSO
                      }
                    },
                    child: const Text('Aggiorna Profilo!'),
                  ),
                  const Divider(height: 32),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: isDark,
                    onChanged: (val) => themeModeProvider.toggleDarkMode(val),
                  ),
                ],
              ),
            ),
    );
  }
}
