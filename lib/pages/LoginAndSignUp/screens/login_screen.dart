
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:homehub/pages/LoginAndSignUp/screens/signup_screen.dart';
import '../../HomeScreen/home_page.dart';
import '../widgets/button.dart';
import '../widgets/snack_bar.dart';
import '../widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passWordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ✅ Step 1: Sign in user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passWordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // ✅ Step 2: Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          // ✅ User exists, navigate to HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          showSnackBar(context, "User data not found. Please sign up again.");
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? "Login failed");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resetPassword() {
    if (emailController.text.isEmpty) {
      showSnackBar(context, "Please enter your email to reset password.");
      return;
    }

    FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim()).then((_) {
      showSnackBar(context, "Password reset email sent. Check your inbox.");
    }).catchError((e) {
      showSnackBar(context, e.message ?? "Error sending password reset email.");
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: height / 2.8,
                  child: Image.asset("images/login1.jpeg"),
                ),
                TextFieldInput(
                  textEditingController: emailController,
                  hintText: "Enter your email",
                  icon: Icons.email,
                  textInputType: TextInputType.emailAddress,
                ),
                TextFieldInput(
                  textEditingController: passWordController,
                  hintText: "Enter your password",
                  icon: Icons.lock,
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: SizedBox(
                    width: screenWidth < 600 ? screenWidth * 0.9 : 600,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: resetPassword, // ✅ Added Forgot Password Functionality
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(onTap: loginUser, text: "Log In"),
                SizedBox(height: height / 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Click here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
