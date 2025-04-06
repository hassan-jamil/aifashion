import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class SurveyScreen extends StatefulWidget {
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Map<String, dynamic> _surveyResponses = {};

  // Next page navigation
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitSurvey();
    }
  }

  // Previous page navigation
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Submit survey and save response
  void _submitSurvey() async {
    FirebaseFirestore.instance.collection('surveys').add(_surveyResponses);

    // Mark survey as completed in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('surveyCompleted', true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Survey submitted successfully!")),
    );

    // Navigate to HomePage after submission
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 320,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "Let me Know You!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 4,
                width: 100,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildBasicInfoPage(),
                    _buildClothingPreferencesPage(),
                    _buildAccessoriesPage(),
                    _buildColorDesignPreferencesPage(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _previousPage,
                      child: Text("Back"),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _nextPage,
                    child: Text(_currentPage == 3 ? "Submit" : "Next"),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Basic Info Page
  Widget _buildBasicInfoPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Are you looking for recommendations for:",
            style: TextStyle(fontSize: 18, color: Colors.black)),
        SizedBox(height: 10),
        _customRadioButton("Gender", ["Men", "Women"]),
        SizedBox(height: 20),
        Text("What type of clothing are you interested in?",
            style: TextStyle(fontSize: 18, color: Colors.black)),
        _customMultiSelect("Clothing Type", ["Pants", "Shirts", "Trousers", "Shalwar Kameez & Kurta"]),
      ],
    );
  }

  // Clothing Preferences Page
  Widget _buildClothingPreferencesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What type of pants do you prefer?",
            style: TextStyle(fontSize: 16, color: Colors.black)),
        _customRadioButton("Pants Type", ["Casual jeans", "Formal trousers", "Cargo pants"]),
        SizedBox(height: 10),
        Text("What type of shirt/top do you prefer?",
            style: TextStyle(fontSize: 16, color: Colors.black)),
        _customRadioButton("Shirt Type", ["Casual t-shirt", "Formal button-down shirt", "Blouse", "Polo shirt"]),
      ],
    );
  }

  // Accessories Page
  Widget _buildAccessoriesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What type of accessories do you usually wear?",
            style: TextStyle(fontSize: 18, color: Colors.black)),
        _customMultiSelect("Accessories", ["Watches", "Belts", "Shoes", "Jewelry"]),
      ],
    );
  }

  // Color and Design Preferences Page
  Widget _buildColorDesignPreferencesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What color palette do you prefer?",
            style: TextStyle(fontSize: 18, color: Colors.black)),
        _customRadioButton("Color Palette", ["Bright and bold", "Neutral and earthy", "Pastel and soft", "Dark and muted"]),
      ],
    );
  }

  // Custom RadioButton
  Widget _customRadioButton(String category, List<String> options) {
    return Column(
      children: options.map((option) {
        return ListTile(
          title: Text(option, style: TextStyle(color: Colors.black)),
          tileColor: _surveyResponses[category] == option ? Colors.blueAccent.withOpacity(0.2) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          trailing: Radio(
            value: option,
            groupValue: _surveyResponses[category],
            onChanged: (val) {
              setState(() {
                _surveyResponses[category] = val;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  // Custom MultiSelect
  Widget _customMultiSelect(String category, List<String> options) {
    return Column(
      children: options.map((option) {
        bool isSelected = _surveyResponses[category]?.contains(option) ?? false;
        return ListTile(
          title: Text(option, style: TextStyle(color: Colors.black)),
          tileColor: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _surveyResponses.putIfAbsent(category, () => []).add(option);
                } else {
                  _surveyResponses[category]?.remove(option);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
