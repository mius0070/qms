import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qms/screens/home_screen.dart';
import 'package:qms/screens/getServiceKey.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';


class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      GetServiceKey.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      GetServiceKey.showNotification(message);
      print('Message clicked!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuScreen()),
      );
    });
  }

  final List<IconData> icons = [
    Iconsax.user_edit, // Medical consultation
    Iconsax.document_text, // Laboratory
    Iconsax.hospital, // Emergency
    Iconsax.activity, // Radiology
  ];

  final List<String> labels = [
    'Consultation',
    'Laboratory',
    'Emergency',
    'Radiology',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Medical Center',
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
      body: Container(
        width: double.infinity,
        color: Color(0xFF077C68),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            children: [
              //  SizedBox(height: 150),
              Text(
                'Queue Management System',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4), // Reduced spacing
              Text(
                'Choose one of the following options',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: GridView.builder(
                    itemCount: icons.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF077C68),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => HomeScreen(label: labels[index]),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icons[index], size: 36,color: Color(0xFF077C68),),
                            SizedBox(height: 8),
                            Text(labels[index], style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    },
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
