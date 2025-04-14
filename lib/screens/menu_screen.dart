import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qms/screens/home_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade300],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 200, 16, 16),
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
              SizedBox(height: 30),
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
                          foregroundColor: Colors.blue.shade700,
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
                            Icon(icons[index], size: 36),
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
