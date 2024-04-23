class Receta{
  int _id;
  String _nombre;
  String _archivo;

  Receta(this._id,this._nombre,this._archivo);

  int get id => _id;
  set id(int id) => _id = id;

  String get nombre => _nombre;
  set nombre(String nombre) => _nombre = nombre;

  String get archivo => _archivo;
  set archivo(String archivo) => _archivo = archivo;

  factory Receta.fromJson(Map<String, dynamic> json){
    return Receta(json['id'], json['nombre'], json['archivo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nombre'] = nombre;
    data['archivo'] = archivo;
    return data;
  }
}