import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prueba/models/session_manager.dart';

class EstudioService{

  Future<File?> downloadFile(String id, String filename) async {
    String url = 'https://simed.med.unne.edu.ar/api/estudio/download/$id';
    String token = await SessionManager.getToken();
    final dir = (await getApplicationDocumentsDirectory()).path;
    final file = new File('$dir/$filename');

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer '+ token
          },
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: Duration(milliseconds: 0),
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return file;
    }catch(e){
      return null;
    }
  }

  Future<dynamic> uploadFile(File archivo, String nombre, String tipo) async {
    final Map<String, dynamic> errorJson = new Map<String, dynamic>();
    var url = Uri.parse('https://simed.med.unne.edu.ar/api/estudio/store');
    String token = await SessionManager.getToken();

    try{

      final bytes = archivo.readAsBytesSync();
      String img64 = base64Encode(bytes);

      var response = await http.post(url, headers: {HttpHeaders.authorizationHeader: 'Bearer '+ token,},
      body: {
      'tipo' : 'false',
      'nombre' : nombre,
      'archivo' : img64,
      }
      );

      //print('mensaje  ---->${response.body}');
      //print('code  ---->${response.statusCode}'); //IMG-20211220-WA0032.jpeg
      switch (response.statusCode) {
        case 200:
          var responseJson = json.decode(response.body);
          return responseJson;
        case 400:
          var responseJson = json.decode(response.body);
          errorJson['status'] = false;
          errorJson['code'] = 400;
          errorJson['message'] = responseJson['message'];
          return errorJson;
        case 401:
          SessionManager.setLogin(false);
          SessionManager.setToken("");

          errorJson['status'] = false;
          errorJson['code'] = 401;
          errorJson['message'] = 'El tiempo expiró, es necesario que inicie sesión nuevamente.';
          return errorJson;
        default:
          errorJson['status'] = false;
          errorJson['code'] = 500;
          errorJson['message'] = 'Error, comuniquese con el administrador.';
          return errorJson;
      }
    }catch(e){
      //print('error ----->${e}');
      errorJson['status'] = false;
      errorJson['code'] = 500;
      errorJson['message'] = 'Error, comuniquese con el administrador.';
      return errorJson;
    }
  }

}