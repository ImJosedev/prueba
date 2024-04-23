
import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:prueba/models/session_manager.dart';

class NotificationService {

  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<String> _streamController = new StreamController.broadcast();
  static Stream<String> get messagesStream => _streamController.stream;

  static Future _onMessageForeground(RemoteMessage message) async{
    String mensaje = message.data['detalle']+','+message.data['titulo']+',open';
    _streamController.add(mensaje);
  }

  static Future _onMessageBackground(RemoteMessage message) async{
    String mensaje = message.data['detalle']+','+message.data['titulo']+',back';
    _streamController.add(mensaje);
  }

  static Future _onMessageTerminated(RemoteMessage message) async{
    String mensaje = message.data['detalle']+','+message.data['titulo']+',finality';
    _streamController.add(mensaje);
  }

  static Future  initializeApp() async{
    await Firebase.initializeApp();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    token = await FirebaseMessaging.instance.getToken();
    SessionManager.setOtherToken(token!);
    log(token!);
    FirebaseMessaging.onBackgroundMessage(_onMessageBackground);
    FirebaseMessaging.onMessage.listen(_onMessageForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageTerminated);

  }

  static closeStreams(){
    _streamController.close();
  }
}