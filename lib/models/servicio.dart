class Servicio {
  int _id;
  String _nombre;
  String _descripcion;
  String _informacion;

  Servicio(this._id,this._nombre,this._descripcion,this._informacion);

  int get id => _id;
  set id(int id) => _id = id;

  String get nombre => _nombre;
  set nombre(String nombre) => _nombre = nombre;

  String get descripcion => _descripcion;
  set descripcion(String descripcion) => _descripcion = descripcion;

  String get informacion => _informacion;
  set informacion(String informacion) => _informacion = informacion;

  factory Servicio.fromJson(Map<String, dynamic> json){
    return Servicio(json['id'], json['nombre'], json['descripcion'],json['informacion']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nombre'] = nombre;
    data['descripcion'] = descripcion;
    data['informacion'] = informacion;
    return data;
  }
}