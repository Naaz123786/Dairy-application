import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/security/security_service.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _navigateToDiary(BuildContext context) async {
    try {
      final securityService = GetIt.I<SecurityService>();
      final isAuthenticated = await securityService.authenticate();

      if (!context.mounted) return;

      if (isAuthenticated) {
        Navigator.pushNamed(context, AppRoutes.diary);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication cancelled or failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardCard(
              context,
              title: 'Personal Diary',
              icon: Icons.book,
              color: Colors.purple.shade100,
              onTap: () => _navigateToDiary(context),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Calendar',
              icon: Icons.calendar_today,
              color: Colors.blue.shade100,
              onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Planner & Routine',
              icon: Icons.checklist,
              color: Colors.teal.shade100,
              onTap: () => Navigator.pushNamed(context, AppRoutes.planner),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upcoming Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text('No upcoming reminders'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDiary(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.black54),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
