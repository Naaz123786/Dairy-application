import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=User&background=random',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'user@example.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildSettingTile(Icons.security, 'Security'),
            _buildSettingTile(Icons.notifications, 'Notifications'),
            _buildSettingTile(Icons.color_lens, 'Theme'),
            _buildSettingTile(Icons.help, 'Help & Support'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
