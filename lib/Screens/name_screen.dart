import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'level_screen.dart';

class NameScreen extends StatefulWidget {
  @override
  namescreenstate createState() {
    return namescreenstate();
  }
}

class namescreenstate extends State<NameScreen> {
  TextEditingController controller = TextEditingController();

  // Saves the player name to Firestore and goes to the next screen
  Future<void> _saveNameAndContinue(BuildContext context) async {
    String name = controller.text.trim();

    // Don't allow empty name
    if (name.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Oops! 😅'),
            content: Text('Please enter your name first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Save player name to Firebase Firestore
    try {
      await FirebaseFirestore.instance.collection('players').add({
        'name': name,
        'joinedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // If Firebase fails, we still let the player continue
      print('Firebase error: $e');
    }

    // Navigate to level screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => levelScreen(name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/png1.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  'Enter Your Name...',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: controller,
                style: TextStyle(color: Colors.purple),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 160,
                height: 50,
                child: ElevatedButton(
                  // Now calls Firebase save + validation ✅
                  onPressed: () => _saveNameAndContinue(context),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
