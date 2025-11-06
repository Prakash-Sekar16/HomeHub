
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:homehub/pages/LoginAndSignUp/screens/login_screen.dart';

// import '../order_details/order_history_page.dart'; // Import Order History Page

// class UserProfile extends StatefulWidget {
//   const UserProfile({super.key});

//   @override
//   State<UserProfile> createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   final User? user = FirebaseAuth.instance.currentUser;
//   String userName = "";
//   bool isLoading = true; 

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   void fetchUserData() async {
//     if (user != null) {
//       DocumentSnapshot userDoc =
//           await FirebaseFirestore.instance.collection("users").doc(user!.uid).get();

//       setState(() {
//         if (userDoc.exists && userDoc.data() != null) {
//           userName = userDoc["name"] ?? "No Name";
//         } else {
//           userName = "No Name";
//         }
//         isLoading = false; 
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("User Profile"),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: Center( 
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: isLoading 
//               ? const CircularProgressIndicator()
//               : Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.grey,
//                       child: Icon(Icons.person, size: 50, color: Colors.blue),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       userName,
//                       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       user?.email ?? "No Email",
//                       style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//                     ),
//                     const SizedBox(height: 30),

//                     // Order History Button
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//                         );
//                       },
//                       icon: const Icon(Icons.history),
//                       label: const Text("View Order History"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                         textStyle: const TextStyle(fontSize: 18),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Logout Button
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         await FirebaseAuth.instance.signOut(); // Logout
//                         Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(builder: (context) => const LoginScreen()),
//                         );
//                       },
//                       icon: const Icon(Icons.logout),
//                       label: const Text("Logout"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                         textStyle: const TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homehub/pages/LoginAndSignUp/screens/login_screen.dart';
import 'dart:ui'; // Import for ImageFilter

import '../order_details/order_history_page.dart';
import 'edit_profile_page.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final User? user = FirebaseAuth.instance.currentUser;
  String userName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      setState(() {
        userName = userDoc["name"] ?? "No Name";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                currentName: userName, 
                currentEmail: user?.email ?? "No Email", // Pass current email
              ),
            ),
          );
          if (result == true) {
            fetchUserData(); // Refresh on return
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.edit, color: Colors.blue),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff2C3E50), Color(0xff34495E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'profile-pic',
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.person, size: 60, color: Color(0xff2c3e50)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? "No Email",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      GlassCard(
                        icon: Icons.history,
                        title: "Order History",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      GlassCard(
                        icon: Icons.logout,
                        title: "Logout",
                        color: Colors.redAccent,
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const GlassCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur effect
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
