class Note {
  String _msg, _dateTime;
  int? _id;
  int _noteImageIndex;

  int get noteImageIndex => _noteImageIndex;

  set noteImageIndex(int value) {
    _noteImageIndex = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  Note(this._id,this._msg, this._dateTime,this._noteImageIndex);

  String get msg => _msg;

  set msg(String value) {
    _msg = value;
  }

  get dateTime => _dateTime;

  set dateTime(value) {
    _dateTime = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['id'] = _id;
    map['msg'] = _msg;
    map['dateTime'] = _dateTime;
    map['noteImageIndex'] = _noteImageIndex;
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      map['id'],
      map['msg'],
      map['dateTime'],
      map['noteImageIndex'],
    );
  }
}
