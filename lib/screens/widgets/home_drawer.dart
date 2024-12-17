
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, 
            ),
            child: Center(
              child: Text(
                'Todo List App', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Menu Items
    
          ListTile(
            leading: Icon(Icons.note),
            title: Text('My Tasks'),
            onTap: () {
              Navigator.pop(context);
             
            },
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup'),
            onTap: () {
              Navigator.pop(context);
             
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Trash'),
            onTap: () {
              Navigator.pop(context);
           
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Rate the app'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
