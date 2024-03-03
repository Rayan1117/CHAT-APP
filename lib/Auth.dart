import "package:chat_app/ImagePick.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "dart:io";
import "package:firebase_storage/firebase_storage.dart";

final _firebase = FirebaseAuth.instance;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

final _form = GlobalKey<FormState>();

bool isLogin = true;

var enteredEmail = '';
var enteredPassword = '';
File? selectedImageFile;
bool isAuthenticating = false;
var enteredUsername = '';

class _AuthState extends State<Auth> {
  void _submit() async {
    final isvalid = _form.currentState!.validate();
    if (!isvalid) {
      return;
    }
    if (!isLogin && selectedImageFile == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (isLogin) {
        final UserCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        print(UserCredentials);
      } else {
        final UserCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        final storageref = FirebaseStorage.instance
            .ref()
            .child('User_images')
            .child('${UserCredentials.user!.uid}.jpeg');
        await storageref.putFile(selectedImageFile!);
        final imageurl = await storageref.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(UserCredentials.user!.uid)
            .set({
          'username': enteredUsername,
          'email': enteredEmail,
          'image_url': imageurl
        });
        setState(() {
          isAuthenticating = false;
        });
      }
      setState(() {
        isAuthenticating = false;
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {
        //..........
      }
      setState(() {
        isAuthenticating = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
    }
  }

  var email;
  void store(val) {
    email = val;
  }

  bool click = false;
  Icon isEye = const Icon(Icons.remove_red_eye);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('assets/images/chat.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  child: Center(
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          if (!isLogin)
                            ImagePick(onPickImage: (imagePicked) {
                              selectedImageFile = imagePicked;
                            }),
                          if (!isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  label: Text("Username"),
                                  hintText: "Enter your name"),
                              validator: (val) {
                                if (val == null ||
                                    val.isEmpty ||
                                    val.trim().length <= 4) {
                                  return "username should atleast be 5 characters";
                                }
                              },
                              onSaved: (val) {
                                enteredUsername = val!;
                              },
                            ),
                          TextFormField(
                            onChanged: (val) {
                              store(val);
                            },
                            decoration: const InputDecoration(
                              labelText: "Email Id",
                              hintText: "enter your email address",
                              hintStyle: TextStyle(fontSize: 15),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@gmail.com")) {
                                return "enter a valid email";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            obscureText: (click == false) ? true : false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: "Password",
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    click = !click;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye,
                                    color: (click == false)
                                        ? null
                                        : Colors.lightBlue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 6 ||
                                  value.trim().length > 30) {
                                return 'password must atleast 6 characters and maximun of 30 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          if (isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                                onPressed: _submit,
                                child: Text(isLogin ? "Sign In" : "Sign Up")),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                                child: Text(isLogin
                                    ? "create a new account"
                                    : "I have already have an account"))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
