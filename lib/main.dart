import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prueba/pages/home.dart';
import 'package:prueba/pages/login.dart';
import 'package:prueba/services/notification_service.dart';

import 'package:opentok_flutter/opentok.dart' as opentok;
import 'package:opentok_flutter/opentok_view.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/session_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService.initNotifications();
  await NotificationService.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //runApp(const MyApp());
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
/*
  @override
  void initState(){
    super.initState();
    //context
    NotificationService.messagesStream.listen((message) {
      var valueMap = message.split(",");
      switch(valueMap[2]){
        case 'open':
          log('message');
          WidgetsBinding.instance!.addPostFrameCallback((_) => showDialogFirebase(context));
          break;
        case 'back':

          break;
        case 'finality':

          break;
        default:

          break;
      }
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SIMED',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.blue,
        ),
        //initialRoute: Login.id,
        routes: {
          Home.id : (context) => Home(),
          Login.id : (context) => Login(),
        },
        home: FutureBuilder(
          future: SessionManager.getLogin(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                /*
                return Container(
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator()),
                );
                */
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasData) {
                  if(snapshot.data != false){
                    return Home();
                  }else{
                    return Login();
                    //return Text("aca se mostraria el home");
                  }
                  //return (snapshot.data == true)? Login() : Home();
                }
                return Container(); // error view
              default:
                return Container(); // error view
            }
          },
        ));
  }
}
