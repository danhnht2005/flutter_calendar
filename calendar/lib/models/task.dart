class Task {
  String? id;
  int? categoryId;
  String? eventName;
  String? from;
  String? to;
  String? background;
  bool? isAllDay;

  Task(
      {this.id,
      this.categoryId,
      this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['categoryId'];
    eventName = json['eventName'];
    from = json['from'];
    to = json['to'];
    background = json['background'];
    isAllDay = json['isAllDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['categoryId'] = categoryId;
    data['eventName'] = eventName;
    data['from'] = from;
    data['to'] = to;
    data['background'] = background;
    data['isAllDay'] = isAllDay;
    return data;
  }
}