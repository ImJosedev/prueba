import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:prueba/models/session_manager.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final baseUrl = 'https://simed.med.unne.edu.ar/api';

  Future<dynamic> register(String email, String password) async {
    try {
      var uri = Uri.http(baseUrl, '/auth/register');
      final res = await http.post(uri, body: {
        'email': email,
        'password': password,
      });

      return res.body;
    } finally {
      // done you can do something here
    }
  }

  Future<int> authenticateUser(String email, String password) async {
    try {
      //var uri = Uri.http(baseUrl, '/login');
      var url = Uri.parse('https://simed.med.unne.edu.ar/api/login');
      var response = await http.post(url, body: {
          'email': email, 'password': password});
      //log('Response status: ${response.statusCode}');
      //log('Response body: ${response.body}');
      switch (response.statusCode) {
        case 200:
          SessionManager.setLogin(json.decode(response.body)['status']);
          SessionManager.setToken(json.decode(response.body)['token']); //old
          // SessionManager.setToken(json.decode(response.body)['token']['original']['access_token']); //new
          SessionManager.setEmail(email);
          return 200;
        case 401:
          return 401;
        default:
          return 500;
      }
    } on SocketException {
      return 500;
    }
  }

  //////////////////////new function////////////////////////////////////// 
  // Future<void> refresh() async{
  //   try {
  //     var url =Uri.parse('https://simed.med.unne.edu.ar/api/refresh');
  //     String token =await SessionManager.getToken();
  //     var response = await http.post(url, headers: {HttpHeaders.authorizationHeader: 'Bearer' + token});
  //     switch (response.statusCode){
  //       case 200:
  //       SessionManager.setToken(json.decode(response.body)['token']['original']['access_token']);
  //       break;
  //       default:
  //       log("switcd default refresh method");
  //       break;

  //     }
  //   } on SocketException{
  //     log("Socket exception in refresh method");
  //   }
  // }

///////////////////////////////////////////////////////////////////////////////////
  Future<dynamic> authenticateCheck() async {
    final Map<String, dynamic> errorJson = new Map<String, dynamic>();
    errorJson['status'] = false;
    errorJson['message'] = 'Error, comuniquese con el administrador.';

    try {
      var url = Uri.parse('https://simed.med.unne.edu.ar/api/v2/check');
      String token = await SessionManager.getToken();
      //log('token del check: ${token}');
      String  token_firebase = await SessionManager.getOtherToken();
      var response = await http.post(url, headers: {HttpHeaders.authorizationHeader: 'Bearer '+ token,}, body: {
        'identificador' : token_firebase
      });
      //log('responseJson: ${response.statusCode}');
      switch (response.statusCode) {
        case 200:
          var responseJson = json.decode(response.body);
          if(responseJson['status'] == false) {
            SessionManager.setLogin(false);
            SessionManager.setToken("");
          }
          return responseJson;
        default:
          SessionManager.setLogin(false);
          SessionManager.setToken("");
          return errorJson;
      }
    } catch(e) {
      //log('Response status: 500');
      if(e is SocketException){
        //treat SocketException
        log("Socket exception: ${e.toString()}");
      }
      else if(e is TimeoutException){
        //treat TimeoutException
        log("Timeout exception: ${e.toString()}");
      }
      else log("Unhandled exception: ${e.toString()}");
      return errorJson;
    }
  }
}
