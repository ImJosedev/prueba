import 'package:prueba/models/servicio.dart';
import 'package:prueba/models/sintoma.dart';

class Institucion{
  int _id;
  String _nombre;
  bool _publico;
  List<Servicio> _servicios;
  List<Sintoma> _sintomas;

  Institucion(this._id,this._nombre,this._publico,this._servicios, this._sintomas);

  int get id => _id;
  set id(int id) => _id = id;

  String get nombre => _nombre;
  set nombre(String nombre) => _nombre = nombre;

  bool get publico => _publico;
  set publico(bool publico) => _publico = publico;

  List<Servicio> get servicios => _servicios;
  set servicios(List<Servicio> servicios) => _servicios = servicios;

  List<Sintoma> get sintomas => _sintomas;
  set sintomas(List<Sintoma> sintomas) => _sintomas = sintomas;

  factory Institucion.fromJson(Map<String, dynamic> json,jsonSintomas){
    List<Servicio> servicios = [];
    for (var value in json['tipos_consulta']) {
      servicios.add(Servicio.fromJson(value));
    }

    List<Sintoma> sintomas = [];
    jsonSintomas.forEach((data) {
      sintomas.add(Sintoma.fromJson(data));
    });

    return Institucion(json['id'], json['nombre'], json['publico'], servicios, sintomas);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nombre'] = nombre;
    data['publico'] = publico;
    data['servicios'] = servicios;
    data['sintomas'] = sintomas;
    return data;
  }
}
