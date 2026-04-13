import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'name_screen.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _showBestScores(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(5)
          .get();

      Navigator.pop(context);
      List<Widget> scoreRows = [];

      if (snapshot.docs.isEmpty) {
        scoreRows.add(
          Text(
            'No scores yet!\nPlay a game first 🎮',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        );
      } else {
        for (int i = 0; i < snapshot.docs.length; i++) {
          Map<String, dynamic> data =
              snapshot.docs[i].data() as Map<String, dynamic>;

          scoreRows.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${i + 1}. ${data['name'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${data['score'] ?? 0} pts  •  ${data['level'] ?? ''}',
                    style: TextStyle(fontSize: 15, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          );
        }
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('🏆 Best Scores'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: scoreRows,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Error'),
            content: Text('Could not load scores.\nCheck your connection.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
      print('Firebase error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/png3.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Flipster Game🤯',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return NameScreen();
                      }),
                    );
                  },
                  child: Text('Start Game'),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Settings'),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showBestScores(context),
                  child: Text('Best Score'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
