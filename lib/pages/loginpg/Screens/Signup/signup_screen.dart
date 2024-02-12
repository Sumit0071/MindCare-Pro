import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../responsive.dart';
import '../../components/background.dart';
import '../../components/already_have_an_account_acheck.dart';
import '../Login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: Background(
        child: SingleChildScrollView(
          child: Container(
            width: 325.0, // Set a fixed width for the form container
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignUpScreenTopImage(
                  imageWidth:
                      400.0, // Set a different width for SignUpScreenTopImage
                ),
                SignUpForm(),
                SizedBox(
                    height: defaultPadding * 12), // Added height for scrolling
                // Additional widgets or content below SignUpForm
              ],
            ),
          ),
        ),
      ),
      desktop: Background(
        child: SingleChildScrollView(
          child: Container(
            width: 325.0, // Set a fixed width for the form container
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignUpScreenTopImage(
                  imageWidth:
                      400.0, // Set a different width for SignUpScreenTopImage
                ),
                SignUpForm(),
                SizedBox(
                    height: defaultPadding * 12), // Added height for scrolling
                // Additional widgets or content below SignUpForm
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(
          imageWidth: 400,
        ),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
        // const SocalSignUp()
      ],
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        User? user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'username': _usernameController.text,
          });
        }
        // Registration successful, navigate to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
          ),
        );
      } catch (e) {
        // Handle registration errors here
        print("Error during registration: $e");

        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // The email address is already in use by another account
          // You can show a Snackbar or any other UI to inform the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account already exists for this email.'),
            ),
          );
        }
        // Add more specific error handling if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Your username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 1),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: _signUp,
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SignUpScreenTopImage extends StatelessWidget {
  final double imageWidth;

  const SignUpScreenTopImage({
    super.key,
    required this.imageWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Sign Up".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset(
                "assets/images/signup_pic.jpg",
                height: 400.0,
                width: imageWidth, // Set the width dynamically
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
