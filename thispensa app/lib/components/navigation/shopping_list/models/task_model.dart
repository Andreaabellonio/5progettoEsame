class Task {
  String id;
  String title;
  String priority;
  int status;
  //da concludere
  int qta;

  Task({this.title, this.qta, this.priority, this.status});
  Task.withId({this.id, this.title, this.qta, this.priority, this.status});

  //richiamata per prendere i dati dell'oggetto e caricarli sal db
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['idProdotto'] = id;
    }
    map['idProdotto'] = id;
    map['titolo'] = title;
    map['qta'] = qta;
    map['priorita'] = priority;
    map['status'] = status;

    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
        id: map['idProdotto'],
        title: map['titolo'],
        qta: map['qta'],
        priority: map['priorita'],
        status: map['status']);
  }
}
