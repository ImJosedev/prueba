import 'package:prueba/models/servicio.dart';
import 'package:prueba/models/sintoma.dart';

import 'institucion.dart';

class Consulta{
  int _id;
  String? _sesion;
  String? _token;
  String _estado;
  bool _consentimiento;
  String? _turno;
  String? _comentario;
  List<Sintoma> _sintomas;
  Servicio _servicio;
  Institucion _institucion;

  Consulta(this._id,this._sesion,this._token,this._estado,this._consentimiento,this._turno,this._comentario,this._sintomas,this._servicio,this._institucion);

  int get id => _id;
  set id(int id) => _id = id;

  Servicio get servicio => _servicio;
  set servicio(Servicio servicio) => _servicio = servicio;

  Institucion get institucion => _institucion;
  set institucion(Institucion institucion) => _institucion = institucion;

  String? get sesion => _sesion;
  set sesion(String? sesion) => _sesion = sesion;

  String? get token => _token;
  set token(String? token) => _token = token;

  String get estado => _estado;
  set estado(String estado) => _estado = estado;

  bool get consentimiento => _consentimiento;
  set consentimiento(bool consentimiento) => _consentimiento = consentimiento;

  String? get turno => _turno;
  set turno(String? turno) => _turno = turno;

  List<Sintoma> get sintomas => _sintomas;
  set sintomas(List<Sintoma> sintomas) => _sintomas = sintomas;

  String? get comentario => _comentario;
  set comentario(String? comentario) => _comentario = comentario;

  String allSintomas(){
    String resultado = "Sintomas: ";
    sintomas.forEach((row) {
      resultado += row.nombre+", ";
    });
    if(comentario != null){
      resultado += comentario!;
      resultado += ".";
    }else{
      resultado += "Sin comentario.";
    }
    return resultado;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['sesion'] = sesion;
    data['token'] = token;
    data['estado'] = estado;
    return data;
  }

}