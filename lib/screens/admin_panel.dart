import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _callNumber(int number) async {
    setState(() => _isLoading = true);
    try {
      // Update the called number in Firestore to show on DisplayScreen
      await _firestore.collection('called').doc('current').set({
        'number': number,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mark the selected number as called in the waiting collection
      var waitingSnapshot =
          await _firestore
              .collection('waiting')
              .where('number', isEqualTo: number)
              .limit(1)
              .get();

      if (waitingSnapshot.docs.isNotEmpty) {
        await waitingSnapshot.docs.first.reference.update({
          'status': 'called',
          'calledTimestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Number #$number called')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetQueue() async {
    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove('currentNumber');
      prefs.remove('waitingDocId');
      prefs.remove('priority');
      prefs.remove('label');
      // Reset both queue and called numbers to 0
      await _firestore.collection('queue').doc('current').set({
        'number': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('called').doc('current').set({
        'number': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear all waiting entries
      var waitingDocs = await _firestore.collection('waiting').get();
      for (var doc in waitingDocs.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Queue reset to 0')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancal(int currentNumber) async {
    setState(() => _isLoading = true);
    try {
      var queueDoc =
          await _firestore
              .collection('waiting')
              .where('number', isEqualTo: currentNumber)
              .limit(1)
              .get();

      if (queueDoc.docs.isNotEmpty) {
        await queueDoc.docs.first.reference.update({
          'status': 'canceled',
          'calledTimestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Number #$currentNumber is cancelled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Center',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Queue Control',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  _firestore.collection('called').doc('current').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text(
                    'Current Called: #0',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  );
                }
                int currentNumber =
                    snapshot.data!.data() != null
                        ? (snapshot.data!.data()
                                as Map<String, dynamic>)['number'] ??
                            0
                        : 0;
                return Text(
                  'Current Called: #$currentNumber',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('waiting')
                        .orderBy('priority', descending: true)
                        .orderBy('timestamp')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var waitingList = snapshot.data!.docs;

                  if (waitingList.isEmpty) {
                    return const Center(child: Text('No numbers issued yet'));
                  }

                  return ListView.builder(
                    itemCount: waitingList.length,
                    itemBuilder: (context, index) {
                      int number = waitingList[index]['number'];
                      String status = waitingList[index]['status'];
                      String label = waitingList[index]['label'];
                      int priority = waitingList[index]['priority'];
                      bool isCalled = status == 'called';
                      bool isCanceled = status == 'canceled';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              priority == 1
                                  ? Colors.red
                                  : Colors.blue, // rouge si urgent
                          child: Text(
                            '#${index + 1}',
                          ), // numéro d'ordre dans la liste
                        ),

                        title: Text(
                          '\nLabel: $label',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: isCalled ? Colors.grey : Colors.black,
                          ),
                        ),

                        /* Text(
                          '#$number',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: isCalled ? Colors.grey : Colors.black,
                          ),
                        ), */
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  _isLoading || isCalled || isCanceled
                                      ? null
                                      : () => _callNumber(number),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                              ),
                              child: Text(
                                'Call',
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  _isLoading || isCanceled || isCalled
                                      ? null
                                      : () => _cancal(number),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                  onPressed: _resetQueue,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Reset Queue',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.red.shade700,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
