import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../game_screen.dart';

class levelScreen extends StatelessWidget {
  final String name;
  levelScreen({required this.name});

  Future<void> _goToGame(BuildContext context, String level) async {
    try {
      await FirebaseFirestore.instance.collection('level_picks').add({
        'name': name,
        'level': level,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Firebase error: $e');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => gameScreen(name: name, level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/png4.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Level...',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  child: Text('easy'),
                  onPressed: () => _goToGame(context, 'easy'),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  child: Text('medium'),
                  onPressed: () => _goToGame(context, 'medium'),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  child: Text('hard'),
                  onPressed: () => _goToGame(context, 'hard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
