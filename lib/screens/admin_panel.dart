import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qms/screens/getServiceKey.dart';
import 'package:url_launcher/url_launcher.dart';


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
          'Admin Panel',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF077C68),
      ),
      drawer: Drawer(

        child:
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Container(
              width: 150,
              child: Image.asset("images/qms_logo.png"),
            ),
            Center(child: Text("Queue Management System",style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Color(0xFF077C68),
              fontSize: 16,
            ),),),
            Divider(),

            ListTile(
              leading: Icon(Icons.policy),
              title: Text('Privacy policy'),
              onTap:(){
                final url  =Uri.parse("https://www.termsfeed.com/live/382f7171-6249-4cea-9f77-a0c53ae3c8a8");
                launchUrl(url);

              },
            ),
            ListTile(
                leading: Icon(Icons.copy_all_outlined),
                title: Text('Terms and conditions'),
                onTap: () {
                  final url1 = Uri.parse(
                      "https://www.termsfeed.com/live/069a8131-ccd4-499e-a0eb-345aa7da6cf4");
                  launchUrl(url1);
                }
            ),

          ],),

        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                      color: Color(0xFF077C68),
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
                    color: Color(0xFF077C68),
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
                                  : Color(0xFF077C68), // rouge si urgent
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),), // numéro d'ordre dans la liste
                        ),

                        title: Text(
                          '$label',
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
                                  (_isLoading || isCalled || isCanceled)
                                      ? null
                                      : () {
                                        _callNumber(number);
                                        GetServiceKey.sendNotificationToToken(
                                          waitingList[index]['token'],
                                          context,
                                        );
                                        // Appeler la fonction pour envoyer la notification
                                      },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF077C68),shape: CircleBorder(),
                              ),
                              child:Icon(Icons.notifications,color: Colors.white,),

                            ),

                            ElevatedButton(
                              onPressed:
                                  _isLoading || isCanceled || isCalled
                                      ? null
                                      : () => _cancal(number),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: CircleBorder(),
                              ),
                              child:Icon(Icons.delete,color: Colors.white,),
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
                  icon: const Icon(Icons.refresh,color: Colors.white,),
                  label: Text(
                    'Reset Queue',
                    style: GoogleFonts.roboto(fontSize: 16,color: Colors.white),
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
