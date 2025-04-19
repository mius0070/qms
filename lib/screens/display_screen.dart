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
      backgroundColor: Colors.white, // Green background as in the image
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin:const EdgeInsets.only(left: 10.0,right: 10.0) ,
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0),),
                            color: Color(0xFF077C6e),
                          ),
                          child: Text(
                            'Ticket N°',
                            style: GoogleFonts.roboto(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          margin:const EdgeInsets.only(left: 10.0,right: 10.0) ,
                          alignment: Alignment.center,
                          width: double.infinity,

                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0),),
                          color: Color(0xFF077C6e),
                           ),
                          child: Text(
                            '$currentCalledNumber',
                            style: GoogleFonts.roboto(
                              fontSize: 160,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(
                  margin:const EdgeInsets.only(left: 10.0,right: 10.0) ,
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0),),
                    color: Color(0xFF077C6e),
                  ),

                  child:  Text(
                    'Number of waiting',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),

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
                          margin:const EdgeInsets.only(left: 10.0,right: 10.0) ,
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0),),
                            color: Color(0xFF077C6e),
                          ),
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
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    ' : ${entry.value}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                SizedBox(height: 10,),
                Container(
                  height: 40,
                  color: Color(0xFF077C6e),
                  child: Marquee(
                    text: '🏥 Centre Médical    •   Adresse : 12 rue des sciences   •   Horaires : 8h – 18h   •   📞 0555 66 77 88   ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    velocity: 40,
                    blankSpace: 60,
                    showFadingOnlyWhenScrolling: true,
                    fadingEdgeStartFraction: 0.05,
                    fadingEdgeEndFraction: 0.05,
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