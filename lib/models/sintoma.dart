class Sintoma{
  int _id;
  String _nombre;
  String? _comentario;
  bool _selected;

  Sintoma(this._id,this._nombre,this._comentario,this._selected);

  int get id => _id;
  set id(int id) => _id = id;

  String get nombre => _nombre;
  set nombre(String nombre) => _nombre = nombre;

  bool get selected => _selected;
  set selected(bool selected) => _selected = selected;

  String? get comentario => _comentario;
  set comentario(String? comentario) => _comentario = comentario;

  factory Sintoma.fromJson(Map<String, dynamic> json){
    return Sintoma(json['id'], json['nombre'], json['comentario'],false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nombre'] = nombre;
    data['comentario'] = comentario;
    data['selected'] = selected;
    return data;
  }

}