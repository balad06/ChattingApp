import 'package:ChattingApp/login/loginScreen.dart';
import 'package:ChattingApp/pages/chatScreen.dart';
import 'package:ChattingApp/pages/mediaPreview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(stream:FirebaseAuth.instance.authStateChanges() ,builder: (ctx,userSnapShot){
        if (userSnapShot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Loading....'));      
        }
        
        if(userSnapShot.hasData){
          return ChatScreen();
        }
        return LoginPage();
      },),
      routes: {
        ChatScreen.id: (context) => ChatScreen(),
        MediaPreview.id: (context) => MediaPreview(),
      },
    );
  }
}
