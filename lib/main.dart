import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_prueba_tecnica/profile_screen.dart';
import 'package:flutter_prueba_tecnica/register_screen.dart';
//import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

/// Ventana de inicio se sesión
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Inicializando una aplicacion Firebase
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return VentanaLogin();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

/// Ventana de login
class VentanaLogin extends StatefulWidget {
  const VentanaLogin({super.key});

  @override
  State<VentanaLogin> createState() => _VentanaLoginState();
}

class _VentanaLoginState extends State<VentanaLogin> {
  //funcion login
  static Future<User?> loginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    User? user;

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Campos vacíos'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Llene todos los campos'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  child: Text('Entendido'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          );
        },
      );
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'invalid-email':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Correo inválido'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text('Use el formato correo@dom.com'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text('Entendido'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                );
              },
            );
            break;

          case 'user-not-found':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Usuario no encontrado'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text('Verifique los datos ingresados.'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text('Entendido'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                );
              },
            );
            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Error no encontrado"),
              backgroundColor: Colors.red,
            ));
            break;
        }
      } catch (e) {
        print(e);
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    //Text field controler
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Digimob test",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Ingresa a la aplicación: ",
            style: TextStyle(
                color: Colors.black,
                fontSize: 44.0,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 44.0,
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Correo electrónico",
              prefixIcon: Icon(Icons.mail, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 26.0,
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Contraseña",
              prefixIcon: Icon(Icons.lock, color: Colors.black),
            ),
          ),
          const SizedBox(height: 12.0),
          Row(children: [
            const Text(
              "Si aún no tienes una cuenta...",
              style: TextStyle(color: Colors.black),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text(
                '¡Crea una!',
                style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ]),
          const SizedBox(
            height: 80.0,
          ),

          /**
           * En este contenedor se encuentra el botón de ingresar
           */
          Container(
            width: double.infinity,
            child: RawMaterialButton(
              fillColor: const Color(0xFF0069FE),
              elevation: 0.0,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              onPressed: () async {
                //Probemos la aplicacion
                User? user = await loginUsingEmailPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                    context: context);
                if (user != null) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                } //endif
              }, //On pressed
              child: const Text(
                "Ingresar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
