import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFF1AE3B0),
                child: Text('S',
                    style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),
              Text('Sangeet User',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('user@sangeet.app',
                  style:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 28),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(label: 'Following', value: '24'),
                  _StatChip(label: 'Followers', value: '118'),
                  _StatChip(label: 'Playlists', value: '9'),
                ],
              ),
              const SizedBox(height: 32),
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_none,
                label: 'Notifications',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Privacy',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.headphones,
                label: 'Audio Quality',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1AE3B0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Log Out',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF1AE3B0),
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1AE3B0), size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      onTap: onTap,
    );
  }
}
