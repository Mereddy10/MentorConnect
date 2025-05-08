import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'project_list_screen.dart';
import 'schedule_meeting_screen.dart';
import 'applied_projects_screen.dart';
import 'notifications_screen.dart';
import 'student_profile.dart';
import 'student_meetings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final Color themeColor = const Color(0xFF1F3A93);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'Apply for Projects',
        'icon': Icons.work_outline,
        'screen': ProjectListScreen(),
      },
      {
        'title': 'View Applied Projects',
        'icon': Icons.folder_open,
        'screen': AppliedProjectsScreen(),
      },
      {
        'title': 'Schedule a Meeting',
        'icon': Icons.calendar_today_outlined,
        'screen': ScheduleMeetingScreen(),
      },
      {
        'title': 'My Meetings',
        'icon': Icons.video_camera_front,
        'screen': StudentMeetingsScreen(),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_none,
        'screen': NotificationsScreen(),
      },
      {
        'title': 'My Profile',
        'icon': Icons.person_outline,
        'screen': StudentProfile(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildAppDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: dashboardItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = dashboardItems[index];
            return _buildDashboardCard(
              context,
              title: item['title'],
              icon: item['icon'],
              screen: item['screen'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeColor, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: themeColor,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: themeColor, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Student",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: themeColor),
            title: Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
