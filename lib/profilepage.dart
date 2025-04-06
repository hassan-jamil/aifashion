import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final String? profileImagePath;

  ProfilePage({this.profileImagePath});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  String? email;
  String profileImageUrl = "https://via.placeholder.com/150";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        username = user.displayName ?? 'Sami Ullah';
        email = user.email ?? 'No email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/bg2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 60),

            /// Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.profileImagePath != null
                  ? FileImage(File(widget.profileImagePath!))
                  : NetworkImage(profileImageUrl) as ImageProvider,
            ),

            SizedBox(height: 10),

            /// Profile Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      _profileButton(Icons.person, "Username", username ?? "Loading..."),
                      _profileButton(Icons.email, "Email", email ?? "Loading..."),
                      SizedBox(height: 20),
                      _editProfileButton(),
                      Divider(),
                      _logoutButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profile Action Buttons (Show Data)
  Widget _profileButton(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  /// Edit Profile Button
  Widget _editProfileButton() {
    return ElevatedButton.icon(
      onPressed: _openEditDialog,
      icon: Icon(Icons.edit, color: Colors.white),
      label: Text("Edit Profile", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Logout Button
  Widget _logoutButton() {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text("LogOut", style: TextStyle(fontSize: 16, color: Colors.red)),
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    );
  }

  /// Open Dialog for Editing All Fields
  void _openEditDialog() {
    TextEditingController nameController = TextEditingController(text: username);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () async {
              String newUsername = nameController.text.trim();
              String newEmail = emailController.text.trim();
              String newPassword = passwordController.text.trim();

              User? user = _auth.currentUser;

              if (user != null) {
                if (newUsername.isNotEmpty) await user.updateDisplayName(newUsername);
                if (newEmail.isNotEmpty) await user.updateEmail(newEmail);
                if (newPassword.isNotEmpty) await user.updatePassword(newPassword);

                _getUserData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile updated successfully")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
