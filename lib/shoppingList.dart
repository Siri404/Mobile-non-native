class ShoppingList {
  int id;
  String name;

  ShoppingList({ this.id, this.name });

  factory ShoppingList.fromMap(Map<String, dynamic> json) => new ShoppingList(
      id: json["id"],
      name: json["name"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name
  };

  Map<String, dynamic> toMapNoId() => {
    "name": name
  };
}