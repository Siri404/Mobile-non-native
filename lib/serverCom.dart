import 'dart:convert';

import 'package:flutter_app/item.dart';
import 'package:flutter_app/shoppingList.dart';
import 'package:http/http.dart' as http;


class ServerCom {
  static const BASE_URL = "http://192.168.0.101:5000/";
  Future<bool> deleteList(int listId) async {
    try {
      final response = await http.delete(
          BASE_URL + "shoppingLists/" + listId.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateList(ShoppingList shoppingList) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> myJson = shoppingList.toMapNoId();

    try {
      final response = await http.put(
          BASE_URL + "shoppingLists/" + shoppingList.id.toString(), headers: headers,
          body: json.encode(myJson));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> addList(ShoppingList shoppingList) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> myJson = shoppingList.toMapNoId();

    try {
      final response = await http.post(
          BASE_URL + "shoppingLists", headers: headers,
          body: json.encode(myJson));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(int itemId) async {
    try {
      final response = await http.delete(
          BASE_URL + "items/" + itemId.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItem(Item item) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> myJson = item.toMapNoId();

    try {
      final response = await http.put(
          BASE_URL + "items/" + item.id.toString(), headers: headers,
          body: json.encode(myJson));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> addItem(Item item) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> myJson = item.toMapNoId();

    try {
      final response = await http.post(
          BASE_URL + "items", headers: headers,
          body: json.encode(myJson));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendListsData(List<ShoppingList> shoppingLists) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    for(ShoppingList shoppingList in shoppingLists) {
      Map<String, dynamic> myJson = shoppingList.toMap();
      try {
        final response = await http.post(
            BASE_URL + "shoppingLists/sync", headers: headers,
            body: json.encode(myJson));
        if (response.statusCode == 200 || response.statusCode == 201) {
          continue;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }

  }

  Future<bool> sendItemsData(List<Item> items) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    for(Item item in items) {
      Map<String, dynamic> myJson = item.toMap();
      try {
        final response = await http.post(
            BASE_URL + "items/sync", headers: headers,
            body: json.encode(myJson));
        if (response.statusCode == 200 || response.statusCode == 201) {
          continue;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    return true;
  }

}