import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    final user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    String welcomeMessage = _user != null
        ? _user!.isAnonymous
            ? "Bienvenido como invitado a la aplicación"
            : "Bienvenido a la aplicación, ${_user!.displayName}"
        : "Usuario no autenticado";

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(welcomeMessage),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
