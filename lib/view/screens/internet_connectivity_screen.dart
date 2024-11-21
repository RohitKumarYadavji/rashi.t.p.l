import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'artical_screen.dart';

class InternetCheckScreen extends StatefulWidget {
  @override
  _InternetCheckScreenState createState() => _InternetCheckScreenState();
}

class _InternetCheckScreenState extends State<InternetCheckScreen> {
  late Stream<List<ConnectivityResult>> _connectivityStream;

  String _connectionStatus = "Checking...";

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
  }

  // Function to check if the device can actually reach the internet
  Future<bool> _isInternetAvailable() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com'));
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: StreamBuilder<List<ConnectivityResult>>(
          stream: _connectivityStream, // Listen to connectivity changes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                "Checking...",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            } else if (snapshot.hasError) {
              return Text(
                "Error: ${snapshot.error}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
              );
            } else if (snapshot.data == ConnectivityResult.none) {
              _connectionStatus = "Internet Closed";
              return Text(
                _connectionStatus,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
              );
            } else {
              _connectionStatus = "Checking Internet Availability...";
              return FutureBuilder<bool>(
                future: _isInternetAvailable(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      "Rashi Technologies",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
                    );
                  } else if (futureSnapshot.data == true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Navigate after the current frame has been rendered
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArticleListScreen()),
                      );
                    });
                    return CircularProgressIndicator(color: Colors.blueGrey,);
                  } else {
                    _connectionStatus = "Internet Closed";
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ArticleListScreen(),));
                      },
                      child: Container(
                        width: 80,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black
                        ),
                        child: Center(
                          child: Text(
                            "Retry",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
