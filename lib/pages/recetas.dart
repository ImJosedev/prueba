import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:prueba/models/receta.dart';
import 'package:prueba/services/receta_service.dart';

class Recetas extends StatefulWidget {
  const Recetas({Key? key}) : super(key: key);

  @override
  _RecetasState createState() => _RecetasState();
}

class _RecetasState extends State<Recetas> {
  List<Receta> recetas = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _list());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recetas médicas"),
        //centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: ListView.builder(itemCount: recetas.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.1, horizontal: 0.1),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: (recetas[index].archivo.endsWith("pdf")) ?
                    Icon(Icons.picture_as_pdf_rounded, color: Colors.red) : Icon(Icons.image_rounded, color: Colors.indigo),
                    onTap: () {
                      //log("solo aca");
                      _downloadReceta(recetas[index]);
                    },
                    title: Text(recetas[index].archivo),
                    trailing: Icon(Icons.download_rounded),
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
    RecetaService recetaService = RecetaService();
    var data = await recetaService.listRecetas();
    if(data['status'] == true) {
      var jsonRecetas = data['recetas'];
      jsonRecetas.forEach((result){
        Receta objectReceta = Receta.fromJson(result);
        setState(() {
          recetas.add(objectReceta);
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

  Future _downloadReceta (Receta object) async{
    RecetaService recetaService = RecetaService();
    final file = await recetaService.downloadFile(object.id.toString(), object.archivo);
    if(file == null){
      return;
    }else{
      OpenFile.open(file.path);
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
