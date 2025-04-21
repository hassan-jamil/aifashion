import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'subcategory.dart';
import 'profilepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _profileImagePath;

  final List<Widget> _pages = [
    HomeContent(),
    AIFashionPage(),
    WardrobePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? "User";

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.black,
        activeColor: Colors.white,
        color: Colors.white70,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.auto_awesome, title: 'AI Fashion'),
          TabItem(icon: Icons.dashboard_outlined, title: 'Wardrobe'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Welcome, $userName",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(profileImagePath: _profileImagePath),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: _profileImagePath != null
                    ? FileImage(File(_profileImagePath!))
                    : AssetImage('asset/logo.jpg') as ImageProvider,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<String> outfitImages = [
    "asset/outfit1.jpg",
    "asset/outfit2.jpg",
    "asset/outfit3.jpg",
    "asset/outfit4.jpg",
    "asset/outfit5.jpg",
  ];

  final List<String> brands = ["CHANEL", "DION", "HERMES", "GUCK"];
  final List<String> brandImages = [
    "asset/logo1.webp",
    "asset/logo2.jpg",
    "asset/logo3.png",
    "asset/logo4.jpg",
  ];

  final List<String> categories = ["Casual", "Formal", "Sportswear", "Party Wear"];
  final List<String> categoryImages = [
    "asset/logo1.webp",
    "asset/logo2.jpg",
    "asset/logo3.png",
    "asset/logo4.jpg",
  ];

  final Map<String, List<String>> brandSubcategories = {
    "CHANEL": ["asset/chanel1.jpg", "asset/chanel2.jpg", "asset/chanel3.jpg"],
    "DION": ["asset/dion1.jpg", "asset/dion2.jpg", "asset/dion3.jpg"],
    "HERMES": ["asset/hermes1.jpg", "asset/hermes2.jpg", "asset/hermes3.jpg"],
    "GUCK": ["asset/guck1.jpg", "asset/guck2.jpg", "asset/guck3.jpg"],
  };

  final Map<String, List<String>> categorySubcategories = {
    "Casual": ["asset/casual1.jpg", "asset/casual2.jpg", "asset/casual3.jpg"],
    "Formal": ["asset/formal1.jpg", "asset/formal2.jpg", "asset/formal3.jpg"],
    "Sportswear": ["asset/sport1.jpg", "asset/sport2.jpg", "asset/sport3.jpg"],
    "Party Wear": ["asset/party1.jpg", "asset/party2.jpg", "asset/party3.jpg"],
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'asset/bg2.jpg',
            fit: BoxFit.fill,
          ),
        ),
        // Foreground Content
        SingleChildScrollView(
          child: Container(
            color: Colors.black.withOpacity(0.3), // Optional overlay for readability
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "AI Outfit Recommendations",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text("Brands", style: _sectionStyle()),
                SizedBox(height: 10),
                _buildHorizontalList(context, brands, brandImages, brandSubcategories),

                SizedBox(height: 20),
                Text("Categories", style: _sectionStyle()),
                SizedBox(height: 10),
                _buildHorizontalList(context, categories, categoryImages, categorySubcategories),

                SizedBox(height: 20),
                Text("Outfit Ideas", style: _sectionStyle()),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: outfitImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            outfitImages[index],
                            width: 150,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _sectionStyle() {
    return TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);
  }

  Widget _buildHorizontalList(BuildContext context, List<String> titles,
      List<String> images, Map<String, List<String>> subcategories) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubcategoryPage(
                    title: titles[index],
                    images: subcategories[titles[index]]!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      images[index],
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    titles[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AIFashionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("AI Fashion Page"),
    );
  }
}

class WardrobePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Wardrobe Page"),
    );
  }
}
