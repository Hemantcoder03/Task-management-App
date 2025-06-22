class Task {
  String _title, _type, _insertedDate, _time;
  int? _id,_remainderTime;
  int _status;

  Task(this._id, this._title, this._type, this._insertedDate, this._time, this._remainderTime,this._status);

  int get status => _status;

  set status(int value) {
    _status = value;
  }

  get insertedDate => _insertedDate;

  set insertedDate(value) {
    _insertedDate = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  get type => _type;

  set type(value) {
    _type = value;
  }

  get time => _time;

  set time(value) {
    _time = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  get remainderTime => _remainderTime;

  set remainderTime(value) {
    _remainderTime = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['id'] = _id;
    map['title'] = _title;
    map['type'] = _type;
    map['insertedDate'] = _insertedDate;
    map['time'] = _time;
    map['remainderTime'] = _remainderTime;
    map['status'] = _status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      map['id'],
      map['title'],
      map['type'],
      map['insertedDate'],
      map['time'],
      map['remainderTime'],
      map['status'],
    );
  }
}
