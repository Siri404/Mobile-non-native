class Item {
  int id;
  int list_id;
  int price;
  String name;

  Item({ this.id, this.list_id, this.price, this.name });

  factory Item.fromMap(Map<String, dynamic> json) => new Item(
      id: json["id"],
      list_id: json["list_id"],
      price: json["price"],
      name: json["name"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "list_id": list_id,
    "price": price,
    "name": name
  };

  Map<String, dynamic> toMapNoId() => {
    "list_id": list_id,
    "price": price,
    "name": name
  };
}