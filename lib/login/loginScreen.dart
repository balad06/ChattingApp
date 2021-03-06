import 'package:ChattingApp/widgets/imagePicker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum AuthMode { Signup, Login }

class LoginPage extends StatefulWidget {
  static const String id = '/LoginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'username': '',
    'password': '',
  };
  File _userImageFile;

  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _submitButton(BuildContext context) {
    return InkWell(
      hoverColor: Colors.purple[900],
      onTap: () {
        setState(() {});
        _submit(context);
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * .45,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.amber,
        ),
        child: Text(
          _authMode == AuthMode.Login ? 'Login' : 'Register',
          style: TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    if (_authMode == AuthMode.Login) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'New Here?',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                _switchAuthMode();
              },
              child: Text(
                'Register',
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (_authMode == AuthMode.Signup) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Have an Account?',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                _switchAuthMode();
              },
              child: Text(
                'Login here',
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
              child: Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
        ],
      ),
    );
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _submit(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState.save();
    setState(() {});
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (_authMode == AuthMode.Login) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: _authData['email'].trim(),
            password: _authData['password'].trim());
      } else {
        setState(() {
          _isLoading = false;
        });
        if (_userImageFile == null) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Please Pick a Image.'),
          ));
          return;
        }
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: _authData['email'].trim(),
            password: _authData['password'].trim());
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child(_auth.currentUser.uid + '.jpg');
        await ref.putFile(_userImageFile).whenComplete(() => null);
       final imageUrl= await  ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set({
          'username': _authData['username'],
          'email': _authData['email'],
          'image_url':imageUrl,
        });
      }
    } on PlatformException catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
      var errorMessage = 'Couldn\'t authenticate ';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'email is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'INVALID_EMAIL ';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'WEAK_PASSWORD';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD';
      }
      _showErrorDialog(errorMessage);
    }
  }

  Widget _formWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _authMode == AuthMode.Signup
                      ? UserImage(_pickedImage)
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      key: ValueKey('email'),
                      decoration: InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Invalid email!';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _authData['email'] = value;
                        print(_authData['email']);
                      },
                    ),
                  ),
                  _authMode == AuthMode.Signup
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: _authMode == AuthMode.Signup,
                            key: ValueKey('user'),
                            decoration: InputDecoration(labelText: 'UserName'),
                            validator: (value) {
                              if (value.isEmpty || value.length < 4) {
                                return 'Invalid Username!';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _authData['username'] = value;
                              print(_authData['username']);
                            },
                          ),
                        )
                      : Container(),
                  TextFormField(
                    key: ValueKey('pass'),
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password is too short!';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                      print(_authData['password']);
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget checkboxorforgot() {
    if (_authMode == AuthMode.Login) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {},
          child: Text(
            'Forgot Password ?',
            style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _authMode == AuthMode.Login
                        ? SizedBox(height: height * .125)
                        : SizedBox(height: height * .05),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        alignment: Alignment.center,
                        child: _authMode == AuthMode.Login
                            ? Row(
                                children: [
                                  Container(
                                    color: Colors.amber,
                                    height: 35,
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Login To Your ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'account',
                                    style: TextStyle(fontSize: 30),
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    color: Colors.amber,
                                    height: 35,
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Register ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'Now',
                                    style: TextStyle(fontSize: 30),
                                  )
                                ],
                              )),
                    SizedBox(height: height * .015),
                    _formWidget(),
                    SizedBox(height: height * .0015),
                    checkboxorforgot(),
                    SizedBox(height: height * .04),
                    _isLoading
                        ? CircularProgressIndicator()
                        : _submitButton(context),
                    _createAccountLabel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
