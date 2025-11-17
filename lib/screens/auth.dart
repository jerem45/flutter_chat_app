import 'package:chatapp/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _haveAccount = false;
  var _userEmail = '';
  var _userPassword = '';
  File? _userImgSelected;
  var _userIsAuth = false;
  var _username = '';

  void _submitForm() async {
    final formIsValid = _formKey.currentState!.validate();
    if (!formIsValid) {
      return;
    }

    _formKey.currentState!.save();

    if (_haveAccount) {
      try {
        setState(() {
          _userIsAuth = true;
        });
        final sendDataUser = await _firebase.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        setState(() {
          _userIsAuth = false;
        });
        // print(sendDataUser);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'invalid-email') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    } else {
      try {
        setState(() {
          _userIsAuth = true;
        });
        //subscribe user
        if (_userImgSelected == null) {
          return;
        }

        if (_username.trim().isEmpty || _username.trim().length > 20) {
          return;
        }

        final sendDataUser = await _firebase.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        // print(sendDataUser);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${sendDataUser.user!.uid}.jpg');
        await storageRef.putFile(_userImgSelected!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(sendDataUser.user!.uid).set({
          'username': _username,
          'email': _userEmail,
          'image_url': imageUrl,
        });
        setState(() {
          _userIsAuth = false;
        });
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //code ^pour gerer les erreur on peut voir tout les code error au qurvol de : createUserWithEmailAndPassword
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                child: Image.asset('assets/images/chat.png', width: 150, height: 150),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          !_haveAccount
                              ? UserImagePicker(
                                  userImageSelected: (value) {
                                    setState(() {
                                      _userImgSelected = value;
                                    });
                                  },
                                )
                              : SizedBox(),
                          TextFormField(
                            decoration: InputDecoration(label: Text("E-mail")),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                return 'Erreur lors de la saisie';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _userEmail = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(label: Text("Mot de passe")),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6 || value.isEmpty) {
                                return 'Mot de passe invalide : 6 carractéres minimum ';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _userPassword = newValue!;
                            },
                          ),
                          !_haveAccount
                              ? TextFormField(
                                  decoration: InputDecoration(label: Text("Nom utilisateur")),
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Erreur lors de la saisie du Nom';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _username = newValue!;
                                  },
                                )
                              : SizedBox(),
                          SizedBox(height: 20),
                          if (_userIsAuth) const CircularProgressIndicator(),
                          if (!_userIsAuth)
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: _haveAccount == false
                                  ? Text("Inscription")
                                  : Text("Connexion"),
                            ),
                          SizedBox(height: 10),
                          if (_userIsAuth) const CircularProgressIndicator(),
                          if (!_userIsAuth)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _haveAccount = !_haveAccount;
                                });
                              },
                              child: _haveAccount == false
                                  ? Text("Vous avez déja un compte ?")
                                  : Text("Crée un compte"),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
