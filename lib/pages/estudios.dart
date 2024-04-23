

import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:prueba/models/estudio.dart';
import 'package:prueba/services/estudio_service.dart';

class Estudios extends StatefulWidget {
  final List<Estudio> objectEstudios;
  const Estudios({Key? key, required List<Estudio> this.objectEstudios}) : super(key: key);

  @override
  _EstudiosState createState() => _EstudiosState(objectEstudios);
}

class _EstudiosState extends State<Estudios> {
  File? _file = null;
  String _name = '';
  String _type = '';
  List<Estudio> objectEstudios;

  _EstudiosState(this.objectEstudios);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Estudios y examenes médicos"),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: ListView.builder(itemCount: objectEstudios.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.1, horizontal: 0.1),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: (objectEstudios[index].archivo.endsWith("pdf")) ?
                    Icon(Icons.picture_as_pdf_rounded, color: Colors.red) : Icon(Icons.image_rounded, color: Colors.indigo),
                    onTap: () {
                      _downloadEstudio(objectEstudios[index]);
                    },
                    title: Text(objectEstudios[index].archivo),
                    trailing: Icon(Icons.download_rounded),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        child: ElevatedButton(
          child: const Text('Subir nuevo archivo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            //primary: Colors.purple,
          ),
          onPressed: () {
            _uploadFile();
          },
        ),
      ),
    );
  }

  Future _downloadEstudio (Estudio object) async{
    EstudioService estudioService = EstudioService();
    final file = await estudioService.downloadFile(object.id.toString(), object.archivo);
    if(file == null){
      return;
    }else{
      OpenFile.open(file.path);
    }
  }

  void _uploadFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png','jpg', 'pdf'],
    );

    if (result != null) {

      PlatformFile file = result.files.first;
      String? path = file.path;
      setState(() {
        _file = File(path!);
        _name = file.name;
        _type = file.extension!;
      });

      EstudioService estudioService = EstudioService();
      var data = await estudioService.uploadFile(_file!,_name,_type);
      
      if(data['status'] == true) {
        Estudio obj = Estudio.fromJson(data['estudio']);
        setState(() {
          objectEstudios.add(obj);
        });
      }else{
        if(data['code'] == 401){
          Navigator.pop(context,'false');
        }else{
          _alertDialog(data['message']);
        }
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
