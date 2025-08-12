import 'package:flutter/material.dart';

import '../../../widgets/login/savejob/bottom_nav.dart';

class NoSavingsScreen extends StatelessWidget {
  const NoSavingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Column(
              children: [
                Text('No Savings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.deepPurple)),
                SizedBox(height: 10),
                Text(
                  "You don't have any jobs saved, please\nfind it in search to save jobs",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                // Your custom image -- use placeholder for now.
                SizedBox(
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 32,
                        child: Container(
                          height: 60, width: 55,
                          decoration: BoxDecoration(
                            color: Colors.amber[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Container(
                        height: 84, width: 70,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned(
                        right: 28,
                        child: Container(
                          height: 54, width: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 220, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('FIND A JOB', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                    onPressed: () {/*...*/},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(selectedIndex: 4, onTap: (_) {}),
    );
  }
}
