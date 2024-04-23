class Estudio{
  int _id;
  String _nombre;
  String _archivo;
  bool _selected;

  Estudio(this._id,this._nombre,this._archivo,this._selected);

  int get id => _id;
  set id(int id) => _id = id;

  String get nombre => _nombre;
  set nombre(String nombre) => _nombre = nombre;

  String get archivo => _archivo;
  set archivo(String archivo) => _archivo = archivo;

  bool get selected => _selected;
  set selected(bool selected) => _selected = selected;

  factory Estudio.fromJson(Map<String, dynamic> json){
    return Estudio(json['id'], json['nombre'], json['archivo'],false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nombre'] = nombre;
    data['archivo'] = archivo;
    data['selected'] = selected;
    return data;
  }
}