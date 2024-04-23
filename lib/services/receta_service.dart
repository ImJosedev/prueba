import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prueba/models/session_manager.dart';
import 'package:http/http.dart' as http;

class RecetaService{

  Future<dynamic> listRecetas() async {
    final Map<String, dynamic> errorJson = new Map<String, dynamic>();

    try {
      var url = Uri.parse('https://simed.med.unne.edu.ar/api/recetas/list');
      String token = await SessionManager.getToken();
      var response = await http.post(url, headers: {HttpHeaders.authorizationHeader: 'Bearer '+ token,});
      switch (response.statusCode) {
        case 200:
          var responseJson = json.decode(response.body);
          return responseJson;
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
    } on SocketException {
      errorJson['status'] = false;
      errorJson['code'] = 500;
      errorJson['message'] = 'Error, comuniquese con el administrador.';
      return errorJson;
    }
  }

  Future<File?> downloadFile(String id, String filename) async {
    String url = 'https://simed.med.unne.edu.ar/api/receta/download/$id';
    String token = await SessionManager.getToken();
    final dir = (await getApplicationDocumentsDirectory()).path;
    final file = new File('$dir/$filename');
    //http.Client client = new http.Client();
    //var req = await client.get(Uri.parse(url),headers: {HttpHeaders.authorizationHeader: 'Bearer '+ token,});
    //var bytes = req.bodyBytes;
    //await file.writeAsBytes(bytes);
    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer '+ token
          },
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: Duration (milliseconds: 0) ,
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

}