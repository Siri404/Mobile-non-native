import 'dart:async';

import 'package:flutter_app/shoppingList.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_app/item.dart';

class DatabaseProvider {
  Future<Database> getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), "shoppingList.db"),
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE lists(id INTEGER PRIMARY KEY, name Text)"
          );
          await db.execute(
              "CREATE TABLE items(id INTEGER PRIMARY KEY, list_id INTEGER "
                  "NOT NULL, price INTEGER, name TEXT, "
                  "FOREIGN KEY (list_id) REFERENCES lists (id) ON DELETE CASCADE)"
          );
        },
        version: 1
    );
  }

  Future<List<Item>> getItems(ShoppingList list) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        "items",
        where: "list_id = ?",
        whereArgs: [list.id]
    );
    return List.generate(maps.length, (i) {
      return Item(
          id: maps[i]["id"],
          price: maps[i]["price"],
          name: maps[i]["name"]
      );
    });
  }

  Future<List<ShoppingList>> getLists() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query("lists");
    return List.generate(maps.length, (i) {
      return ShoppingList(
          id: maps[i]["id"],
          name: maps[i]["name"]
      );
    });
  }

  Future<void> insertItem(Item item) async {
    final Database db = await getDatabase();
    await db.insert(
        "items",
        item.toMapNoId(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> insertList(ShoppingList list) async {
    final Database db = await getDatabase();
    await db.insert(
        "lists",
        list.toMapNoId(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> updateItem(Item item) async {
    final Database db = await getDatabase();
    await db.update(
        "items",
        item.toMap(),
        where: "id = ?",
        whereArgs: [item.id]
    );
  }

  Future<void> updateList(ShoppingList list) async {
    final Database db = await getDatabase();
    await db.update(
        "lists",
        list.toMap(),
        where: "id = ?",
        whereArgs: [list.id]
    );
  }

  Future<void> deleteItem(int id) async {
    final Database db = await getDatabase();
    await db.delete(
        "items",
        where: "id = ?",
        whereArgs: [id]
    );
  }

  Future<void> deleteList(int id) async {
    final Database db = await getDatabase();
    await db.delete(
        "lists",
        where: "id = ?",
        whereArgs: [id]
    );
  }
}