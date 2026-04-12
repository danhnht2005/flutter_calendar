class Categories {
  String? id;
  String? userId;
  String? name;
  String? description;
  String? color;
  bool? isActive;

  Categories({this.id, this.userId, this.name, this.description, this.color, this.isActive});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['userId']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    color = json['color']?.toString();

    final dynamic activeValue = json['isActive'];
    if (activeValue is bool) {
      isActive = activeValue;
    } else if (activeValue is String) {
      isActive = activeValue.toLowerCase() == 'true';
    } else if (activeValue is num) {
      isActive = activeValue != 0;
    } else {
      isActive = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['description'] = description;
    data['color'] = color;
    data['isActive'] = isActive;
    return data;
  }
}