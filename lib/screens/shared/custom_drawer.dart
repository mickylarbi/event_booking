import 'package:event_booking/firebase_services/auth_service.dart';
import 'package:event_booking/screens/home_screen.dart';
import 'package:event_booking/screens/event_screen.dart/my_events_list_screen.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({
    Key? key,
  }) : super(key: key);
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.blue,
      child: ListView(
        shrinkWrap: true,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Elisha Osei Tutu'),
            accountEmail: Text('elishaoseitutu@gmail.com'),
            currentAccountPicture: FlutterLogo(),
          ),
          const Divider(
            height: 50,
            color: Colors.white,
            indent: 14,
            endIndent: 14,
          ),
          ListTile(
            style: ListTileStyle.drawer,
            leading: const Icon(Icons.home),
            textColor: Colors.white,
            iconColor: Colors.white,
            title: const Text('Home'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          ListTile(
            style: ListTileStyle.drawer,
            leading: const Icon(Icons.book_online),
            textColor: Colors.white,
            iconColor: Colors.white,
            title: const Text('My events'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyEventsListScreen()),
                (route) => false,
              );
            },
          ),
          const Divider(
            height: 70,
            color: Colors.white,
            indent: 14,
            endIndent: 14,
          ),
          ListTile(
            style: ListTileStyle.drawer,
            leading: const Icon(Icons.logout),
            textColor: Colors.white,
            iconColor: Colors.white,
            title: const Text('Log out'),
            onTap: () {
              showConfirmationDialog(context, confirmFunction: () {
                auth.signOut(context);
              });
            },
          ),
        ],
      ),
    );
  }
}
