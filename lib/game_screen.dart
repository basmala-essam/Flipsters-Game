import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Screens/home_screen.dart';
import 'Screens/level_screen.dart';

class gameScreen extends StatefulWidget {
  final String name;
  final String level;
  gameScreen({required this.name, required this.level});

  @override
  game_screen_state createState() {
    return game_screen_state();
  }
}

class game_screen_state extends State<gameScreen> {
  List<String> cards = [];
  List<bool> revealed = [];
  List<bool> matched = [];
  int? first_ind;
  int? sec_ind;
  bool waiting = false;

  int score = 0;
  late int timeLeft;
  Timer? _timer;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    if (widget.level == 'easy') {
      cards = ['❤️', '🤩', '❤️', '🤩'];
      timeLeft = 30;
    } else if (widget.level == 'medium') {
      cards = ['🦉', '🦩', '🐧', '🦉', '🦩', '🐧', '🐥', '🐥'];
      timeLeft = 60;
    } else {
      cards = [
        '🍕',
        '🍔',
        '🍨',
        '🍕',
        '🌭',
        '🧁',
        '🍩',
        '🧁',
        '🍔',
        '🌭',
        '🍩',
        '🍨'
      ];
      timeLeft = 90;
    }

    cards.shuffle();
    revealed = List.generate(cards.length, (index) => false);
    matched = List.generate(cards.length, (index) => false);

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft <= 0) {
        timer.cancel();
        setState(() {
          gameOver = true;
        });
        _showTimeUpDialog();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shadowColor: Colors.blueGrey,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('⏰ Time\'s Up!'),
          content:
              Text('Better luck next time, ${widget.name}!\nScore: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
                );
              },
              child: Text('Go Home'),
            ),
          ],
        );
      },
    );
  }

  void oncardTap(int index) {
    if (waiting == true) return;
    if (revealed[index] == true) return;
    if (matched[index] == true) return;
    if (gameOver) return;

    setState(() {
      revealed[index] = true;
    });

    if (first_ind == null) {
      first_ind = index;
    } else if (sec_ind == null) {
      sec_ind = index;
      waiting = true;
      checkcards();
    }
  }

  void checkcards() async {
    await Future.delayed(Duration(seconds: 1));
    if (cards[first_ind!] == cards[sec_ind!]) {
      setState(() {
        matched[first_ind!] = true;
        matched[sec_ind!] = true;
        score += 10;
      });
    } else {
      setState(() {
        revealed[first_ind!] = false;
        revealed[sec_ind!] = false;
      });
    }
    first_ind = null;
    sec_ind = null;
    waiting = false;
    checkwin();
  }

  void checkwin() {
    bool allmatched = true;
    for (int i = 0; i < matched.length; i++) {
      if (matched[i] == false) {
        allmatched = false;
        break;
      }
    }
    if (allmatched == true) {
      _timer?.cancel();

      _saveScoreToFirebase();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shadowColor: Colors.blueGrey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('You Win! 🥳'),
            content: Text(
              'Good Job ${widget.name}\n'
              'Score: $score\n'
              'Time left: $timeLeft seconds',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveScoreToFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('scores').add({
        'name': widget.name,
        'level': widget.level,
        'score': score,
        'timeLeft': timeLeft,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Firebase error: $e');
    }
  }

  int getCrossAxisCount() {
    if (widget.level == 'easy') {
      return 1;
    } else if (widget.level == 'medium') {
      return 2;
    } else {
      return 3;
    }
  }

  Widget buildcard(int index) {
    if (revealed[index] == true) {
      return Text(
        cards[index],
        style: TextStyle(fontSize: 30, color: Colors.white),
      );
    } else {
      return Text(
        '❓',
        style: TextStyle(fontSize: 30, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.name}⚔️ Level ${widget.level}🙈',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/png5.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Score display
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '⭐ Score: $score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: timeLeft <= 10
                            ? Colors.red.withOpacity(0.85)
                            : Colors.deepPurple.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '⏱ $timeLeft s',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: cards.length,
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => oncardTap(index),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: buildcard(index)),
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
    );
  }
}
