import 'package:flutter/material.dart';
import 'post_project_screen.dart';
import 'manage_applications_screen.dart';
import 'faculty_profile.dart';
import 'login_screen.dart';
import 'faculty_meetings_screen.dart';
import 'notifications_screen.dart';
import '../providers/auth_provider.dart';

class FacultyDashboardScreen extends StatelessWidget {
  const FacultyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int facultyId = AuthProvider.currentUserId ?? 0;

    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'Post & Manage Projects',
        'icon': Icons.assignment,
        'screen': PostProjectScreen(),
      },
      {
        'title': 'Review Student Applications',
        'icon': Icons.folder_open,
        'screen': ManageApplicationsScreen(),
      },
      {
        'title': 'View Meeting Requests',
        'icon': Icons.calendar_view_day,
        'screen': FacultyMeetingsScreen(),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications,
        'screen': NotificationsScreen(),
      },
      {'title': 'My Profile', 'icon': Icons.person, 'screen': FacultyProfile()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faculty Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1F3A93),
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        color: Color(0xFFFDF6FF),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dashboardItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
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
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF1F3A93), size: 40),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1F3A93)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, color: Colors.white, size: 50),
                SizedBox(height: 8),
                Text(
                  'Welcome!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFF1F3A93)),
            title: Text('Logout'),
            onTap:
                () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                ),
          ),
        ],
      ),
    );
  }
}
