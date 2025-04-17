import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marquee/marquee.dart';

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF077C6e), // Green background as in the image
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('called')
              .doc('current')
              .snapshots(),
          builder: (context, calledSnapshot) {
            if (calledSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SpinKitCircle(color: Colors.white));
            }
            if (calledSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${calledSnapshot.error}',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              );
            }
            if (!calledSnapshot.hasData || !calledSnapshot.data!.exists) {
              return Center(
                child: Text(
                  'No data available',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              );
            }

            // Extract data from Firestore
            int currentCalledNumber =
                (calledSnapshot.data!.data() as Map<String, dynamic>)['number'] ?? 0;

            return Column(
              children: [
                // Header with logo and title
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: Image.asset("images/qms_logo.png"),
                      ),
                      Container(padding: const EdgeInsets.only(right: 20)),
                      Text(
                        'Queue Management System',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Main ticket number display
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      '$currentCalledNumber',
                      style: GoogleFonts.roboto(
                        fontSize: 150,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Waiting info by label in a row-column layout
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('waiting')
                      .where('status', isNotEqualTo: 'called')
                      .snapshots(),
                  builder: (context, waitingSnapshot) {
                    if (waitingSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: SpinKitCircle(color: Colors.white));
                    }
                    if (waitingSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error fetching waiting count',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      );
                    }

                    // Stream to fetch all possible labels
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('labels').snapshots(),
                      builder: (context, labelsSnapshot) {
                        if (labelsSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: SpinKitCircle(color: Colors.white));
                        }
                        if (labelsSnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error fetching labels',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          );
                        }

                        // Get all labels
                        List<String> allLabels = labelsSnapshot.data?.docs
                            .map((doc) => doc['name'] as String)
                            .toList() ??
                            [];

                        // Group waiting count by label
                        Map<String, int> labelCounts = {};
                        // Initialize all labels with 0
                        for (var label in allLabels) {
                          labelCounts[label] = 0;
                        }
                        // Add counts from waiting collection
                        if (waitingSnapshot.hasData) {
                          for (var doc in waitingSnapshot.data!.docs) {
                            if (doc['status'] != 'canceled') {
                              String label = doc['label'] ?? 'Unknown';
                              labelCounts[label] = (labelCounts[label] ?? 0) + 1;
                            }
                          }
                        }

                        return Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Wrap(
                            spacing: 20, // Space between items horizontally
                            runSpacing: 20, // Space between rows
                            children: labelCounts.entries.map((entry) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    ' : ${entry.value}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    color: Colors.teal.shade800,
                    child: Marquee(
                      text: '🏥 Centre Médical    •   Adresse : 12 rue des sciences   •   Horaires : 8h – 18h   •   📞 0555 66 77 88   ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      velocity: 40,
                      blankSpace: 60,
                      pauseAfterRound: const Duration(seconds: 1),
                      showFadingOnlyWhenScrolling: true,
                      fadingEdgeStartFraction: 0.05,
                      fadingEdgeEndFraction: 0.05,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}