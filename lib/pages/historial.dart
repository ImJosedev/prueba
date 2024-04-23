import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prueba/models/consulta.dart';
import 'package:prueba/models/institucion.dart';
import 'package:prueba/models/servicio.dart';
import 'package:prueba/models/sintoma.dart';
import 'package:prueba/services/consulta_service.dart';

class Historial extends StatefulWidget {
  const Historial({Key? key}) : super(key: key);

  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  List<Consulta> consultas = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _list());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de consultas"),
        //centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: ListView.builder(itemCount: consultas.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      //click en cada elemento
                    },
                    title: Text(consultas[index].institucion.nombre),
                    subtitle: Text('Servicio: '+ consultas[index].servicio.descripcion+'\n'+
                        consultas[index].allSintomas()+'\n'+
                        'Estado: '+consultas[index].estado
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _list() async{
    ConsultaService consultaService = ConsultaService();
    var data = await consultaService.listConsulta();
    if(data['status'] == true) {
      var jsonConsultas = data['consultas'];
      jsonConsultas.forEach((result){

        List<Sintoma> sintomas = [];
        result['sintomas'].forEach((sin){
          Sintoma objectSintoma = Sintoma.fromJson(sin);
          sintomas.add(objectSintoma);
        });

        var jsonUserInsitucion = result['user_institucion'];
        var jsonInstitucion = jsonUserInsitucion['institucion'];

        Institucion objectInstitucion = Institucion(jsonInstitucion['id'], jsonInstitucion['nombre'], jsonInstitucion['publico'], [], []);
        Servicio objectServicio = Servicio.fromJson(result['tipo_consulta']);

        Consulta objectConsulta = Consulta(result['id'], result['sesion'], result['token_pac'], result['estado'],
            result['consentimiento'], result['fecha_turno'], result['comentario_pac'], sintomas,
            objectServicio, objectInstitucion);

        setState(() {
          consultas.add(objectConsulta);
        });
      });
    }else{
      if(data['code'] == 500){
        _alertDialog(data['message']);
      }else{
        Navigator.pop(context,'false');
      }
    }
  }

  Future<void> _alertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atención'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
