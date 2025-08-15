import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesoapp/pages/home_page.dart';
import 'package:flutter/material.dart';

// A stateless widget for the Sign-In screen
class LoginPage extends StatelessWidget {
  // Instance of GoogleAuthService to handle Google Sign-In
  //final GoogleAuthService _authService = GoogleAuthService();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and styling
      appBar: AppBar(
        title: Text("GFG Sign In"), 
        backgroundColor: Colors.green, 
        foregroundColor: Colors.white, 
      ),
      // Main body of the screen
      body: Center(
        // ElevatedButton for Google Sign-In
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green, 
          ),
          // Asynchronous function triggered on button press
          onPressed: () async {
            // Attempt to sign in with Google
            //User? user = await _authService.signInWithGoogle();
            // If sign-in is successful, navigate to the HomeScreen
            /* if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            } */
          },
          // Text displayed on the button
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}