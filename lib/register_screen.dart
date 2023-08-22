import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prueba_tecnica/main.dart';
import 'package:flutter_prueba_tecnica/profile_screen.dart';

//Ventana de registro
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
            return ventanaRegistro();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class ventanaRegistro extends StatefulWidget {
  const ventanaRegistro({super.key});

  @override
  State<ventanaRegistro> createState() => _ventanaRegistroState();
}

class _ventanaRegistroState extends State<ventanaRegistro> {
  static Future<User?> createUserWithEmailAndPassword(
      {required String name,
      required String email,
      required String password,
      required String confirmPassword,
      required BuildContext context}) async {
    User? user;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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
    } else if (password == confirmPassword) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        user = userCredential.user;
        await userCredential.user!.updateDisplayName(name);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message.toString()),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        print(e);
      }
    } else {
      AlertDialog(
        title: Text('Contraseñas distintas'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Verifique que las contraseñas coincidan'),
            ],
          ),
        ),
      );
    }
    return user;
  }

  Future<User?> loginAsGuest(BuildContext context) async {
    try {
      UserCredential guestCredential =
          await FirebaseAuth.instance.signInAnonymously();
      User? guestUser = guestCredential.user;
      return guestUser;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al ingresar como invitado: $e"),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  Future<void> updateName(String name) async {
    try {
      // Obtiene el usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      // Actualiza el nombre del usuario
      await user?.updateDisplayName(name);
      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("¡Nombre de usuario actualizado correctamente!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al registrar nombre de usuario"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          const SizedBox(
            height: 12.0,
          ),
          const Text(
            "Digimob test",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Registrate para acceder ",
            style: TextStyle(
                color: Colors.black,
                fontSize: 44.0,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 44.0,
          ),
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: "Nombre",
              prefixIcon: Icon(Icons.person, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 20.0,
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
            height: 20.0,
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Contraseña",
              prefixIcon: Icon(Icons.lock, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Confirma tu contraseña",
                prefixIcon: Icon(Icons.check, color: Colors.black),
              )),
          const SizedBox(height: 12.0),
          const Text(
            "Completa el registro para acceder",
            style: TextStyle(color: Colors.black),
          ),
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
                User? user = await createUserWithEmailAndPassword(
                    name: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    confirmPassword: _confirmPasswordController.text,
                    context: context);

                if (user != null) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
              },
              child: const Text(
                "Registrar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(
            onPressed: () async {
              // Iniciar sesión como invitado
              User? guestUser = await loginAsGuest(context);
              if (guestUser != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              }
            },
            child: Text(
              'Ingresar como invitado',
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
