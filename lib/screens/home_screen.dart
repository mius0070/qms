import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int? currentNumber;
  String? _waitingDocId;
  bool _hasTakenNumber = false;
  bool _isLoading = false;
  Timer? _timer;
  int? _remainingSeconds;

  Future<void> _takeNumber() async {
    if (_hasTakenNumber) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var queueDoc = await _firestore.collection('queue').doc('current').get();
      int lastNumber = queueDoc.exists ? (queueDoc.data()?['number'] ?? 0) : 0;
      int newNumber = lastNumber + 1;

      await _firestore.collection('queue').doc('current').set({
        'number': newNumber,
        'timestamp': FieldValue.serverTimestamp(),
      });

      var docRef = await _firestore.collection('waiting').add({
        'number': newNumber,
        'status': 'waiting',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        currentNumber = newNumber;
        _waitingDocId = docRef.id;
        _hasTakenNumber = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Convert seconds to a readable MM:SS format
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startCountdown(int initialSeconds) {
    _remainingSeconds = initialSeconds;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Queue Management System',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (currentNumber != null && _waitingDocId != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('waiting')
                            .doc(_waitingDocId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Column(
                              children: [
                                Text(
                                  'Your Number',
                                  style: GoogleFonts.roboto(
                                    fontSize: 24,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '#$currentNumber',
                                  style: GoogleFonts.roboto(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Calculating wait time...',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            );
                          }

                          String status = snapshot.data!['status'];
                          bool isCalled = status == 'called';

                          return Column(
                            children: [
                              Text(
                                'Your Number',
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '#$currentNumber',
                                style: GoogleFonts.roboto(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (isCalled)
                                Text(
                                  'Your turn!',
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection('waiting')
                                      .where('status', isEqualTo: 'waiting')
                                      .snapshots(),
                                  builder: (context, waitSnapshot) {
                                    if (!waitSnapshot.hasData) {
                                      return Column(
                                        children: [
                                          Text(
                                            'Estimated Wait Time',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ],
                                      );
                                    }

                                    int totalWaiting = waitSnapshot.data!.docs.length;
                                    int numbersAhead = totalWaiting - 1; // Exclude user's number
                                    if (numbersAhead < 0) numbersAhead = 0;
                                    const int secondsPerNumber = 600; // 15 min = 900 sec
                                    int initialWaitTimeSeconds = numbersAhead * secondsPerNumber;

                                    // Start or update the countdown timer
                                    if (_remainingSeconds == null || _remainingSeconds! > initialWaitTimeSeconds) {
                                      _startCountdown(initialWaitTimeSeconds);
                                    }

                                    double progressValue = _remainingSeconds != null && initialWaitTimeSeconds > 0
                                        ? _remainingSeconds! / initialWaitTimeSeconds
                                        : 1.0;

                                    return Column(
                                      children: [
                                        Text(
                                          'Estimated Wait Time',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              height: 80,
                                              width: 80,
                                              child: CircularProgressIndicator(
                                                value: progressValue,
                                                strokeWidth: 6,
                                                backgroundColor: Colors.grey.shade300,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _remainingSeconds != null
                                                  ? _formatTime(_remainingSeconds!)
                                                  : _formatTime(initialWaitTimeSeconds),
                                              style: GoogleFonts.roboto(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      )
                    else if (_isLoading)
                      const SpinKitCircle(color: Colors.blue)
                    else
                      Text(
                        'Take a number',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 30),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _hasTakenNumber ? null : _takeNumber,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor:
                          _hasTakenNumber ? Colors.grey : Colors.blue,
                        ),
                        child: Text(
                          _hasTakenNumber ? 'Number Taken' : 'Take Number',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}