import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

const Color yelloww = Color.fromARGB(255, 239, 229, 181);
const Color brownn = Color.fromARGB(255, 36, 17, 5);

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();
  final Color backgroundColor = yelloww;
  final double maxCardWidth = 400.0; // Maximum width for the cards
  final double imageSize = 200.0; // Fixed size for images
  final double maxCardHeight = 500.0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          backgroundColor: yelloww,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brownn,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void signuserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: yelloww,
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (_emailController.text == "") {
        showErrorMessage("Please enter the email");
      } else if (_passwordController.text == "") {
        showErrorMessage("Please enter the password");
      } else
        showErrorMessage("Wrong email or password entered");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              buildPage(
                title: 'Welcome!',
                text:
                    '\nYour companion for a safer journey. Report incidents, view safety heat maps, find the safest routes and more. Safe Street, Safe Stree!',
                imagePath: 'assets/welcome.png',
                size: 220,
              ),
              buildPage(
                title: 'Report Incidents',
                text:
                    'Quickly and anonymously report any incidents or uncomfortable situations. Your report contributes to a safer environment for everyone.',
                imagePath: 'assets/reportsCropped.png',
                size: 250,
              ),
              buildPage(
                title: 'Safety Heat Map',
                text:
                    'Stay informed with real-time safety data. Our dynamic heat map shows areas with reported incidents, helping you navigate your city safely and confidently.',
                imagePath: 'assets/map.png',
                size: 240,
              ),
              buildPage(
                title: 'Safe Routes',
                text:
                    'Find the safest path to your destination. Our app uses real-time data to suggest the best routes, so you can travel with peace of mind, no matter the time of day.',
                imagePath: 'assets/directions.png',
                size: 240,
              ),
              buildPage(
                title: 'Quick Record',
                text:
                    'Capture critical moments quietly. Record audio and video discreetly to ensure you have the evidence you need, when you need it.',
                imagePath: 'assets/record.png',
                size: 250,
              ),
              buildPage(
                title: 'SOS Alert',
                text:
                    'Instantly notify nearby users and local authorities when you\'re in need of help. One tap sends an alert to keep you safe in emergencies.',
                imagePath: 'assets/sos.png',
                size: 250,
              ),
              buildLastPage(), // Last page with the login form
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 7,
                effect: WormEffect(
                  dotColor: Colors.grey,
                  activeDotColor: yelloww,
                  dotHeight: 12,
                  dotWidth: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String title,
    required String text,
    required String imagePath,
    required double size,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
      color: brownn,
      child: Center(
        child: SizedBox(
          height: maxCardHeight,
          width: maxCardWidth,
          child: Card(
            color: yelloww,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  width: size,
                  height: size,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLastPage() {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: brownn // Background color with opacity
              ),
          Positioned(
            left: 0,
            right: 0,
            top: 30, // Adjust the position of the image as needed
            child: Image.asset(
              'assets/homescreen.png', // Your custom background image
              width: 900,
              height: 900,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  // Example of freely positioning login fields and button
                  Container(
                    width: 300,
                    // You can freely set the position using Alignment and Padding
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 200),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: const Color.fromARGB(255, 64, 64, 64)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                                color: const Color.fromARGB(255, 64, 64, 64)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            signuserIn();
                          },
                          child: Text('Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yelloww, // Background color
                            foregroundColor: Colors.black, // Text color
                            minimumSize: Size(150, 50), // Button size
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10), // Padding
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            textStyle: TextStyle(
                              fontSize: 18, // Font size
                              fontWeight: FontWeight.bold, // Font weight
                            ),
                            elevation: 5, // Shadow elevation
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
