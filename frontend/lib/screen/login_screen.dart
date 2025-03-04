import 'package:flutter/material.dart';
import 'package:frontend/service/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Send credentials to the backend and get the JWT
  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$url/api/login'), // backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully received JWT
        final data = json.decode(response.body);
        String jwt = data['userCredential']['_tokenResponse']['idToken'];

        // Store JWT in shared preferences or secure storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle error from backend
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid credentials or server error';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, top: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.35,
                child: Image.asset('lib/images/koreanlogo.png'),
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
              const Text(
                ''
                'Login to your Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'user name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signInWithEmailPassword,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.blueAccent),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 56.0)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                      ),
                      child: const Text('Login',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(
                height: 48,
              ),
              const Text('Or SignIn with '),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.3), // Shadow color with opacity
                            offset: const Offset(0, 4), // Shadow offset (x, y)
                            blurRadius: 6, // Softness of the shadow
                          ),
                        ],
                      ),
                      height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.12,
                      child: Image.asset('lib/images/Facebook.png')),
                  const SizedBox(
                    width: 24,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.3), // Shadow color with opacity
                            offset: const Offset(0, 4), // Shadow offset (x, y)
                            blurRadius: 6, // Softness of the shadow
                          ),
                        ],
                      ),
                      height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.12,
                      child: Image.asset('lib/images/Google.png'))
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Do\'t have an Account ?',
                      style: TextStyle(color: Colors.black54)),
                  TextButton(
                    onPressed: () {
                      // Your action when the text is clicked
                    },
                    child: const Text(
                      'Signup here',
                      style: TextStyle(
                        color: Colors.indigoAccent,
                        decoration: TextDecoration
                            .underline, // Underlined like a hyperlink
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
