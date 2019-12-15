import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';
import 'package:flutter_app/serverCom.dart';
import 'package:flutter_app/shoppingList.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/ItemsWidget.dart';

import 'item.dart';


void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Shopping List',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.purple,
        ),
        home: new ShoppingListsWidget()
    );
  }
}

class ShoppingListsWidget extends StatefulWidget {
  @override
  createState() => new ShoppingListsWidgetState();
}

class ShoppingListsWidgetState extends State<ShoppingListsWidget> {
  DatabaseProvider dbProvider = new DatabaseProvider();
  ServerCom serverCom = new ServerCom();
  var subscription;

  @override
  initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      sendData();
    });
  }

  void sendData() async {
    List<ShoppingList> shoppingLists = await getLists();
    List<Item> items = await getItems();
    serverCom.sendItemsData(items);
    serverCom.sendListsData(shoppingLists);

  }

  Future<List<ShoppingList>> getLists() async {
    return await dbProvider.getLists();
  }

  Future<List<Item>> getItems() async {
    return await dbProvider.getAllItems();
  }

  void addList(ShoppingList list) async {
    await dbProvider.insertList(list);
    if(await checkConnection()) {
      await serverCom.addList(list);
    }
    setState(() {});
  }

  void tryAddList(TextEditingController nameController){
    if(nameController.text.isEmpty){
      Fluttertoast.showToast(
          msg: "Fields empty!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else{
      addList(new ShoppingList(id: -1, name: nameController.text));
      Navigator.pop(context);
    }
  }

  void removeList(int id) async {
    if(await checkConnection()) {
      await dbProvider.deleteList(id);
      await serverCom.deleteList(id);
    }
    else{
      Fluttertoast.showToast(
          msg: "No internet connection!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    setState(() {});
  }

  void tryUpdateList(ShoppingList list, TextEditingController nameController){
    if(nameController.text.isEmpty){
      Fluttertoast.showToast(
          msg: "Fields empty!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else{
      updateList(new ShoppingList(id: list.id, name: nameController.text));
      Navigator.pop(context);
    }
  }
//
  void updateList(ShoppingList list) async {
    if(await checkConnection()) {
      await serverCom.updateList(list);
      await dbProvider.updateList(list);
    }
    else{
      Fluttertoast.showToast(
          msg: "No internet connection!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    setState(() {});
  }

  Future<bool> checkConnection() async {
    var conres = await Connectivity().checkConnectivity();
    if(conres == ConnectivityResult.wifi){
      return true;
    }
    return false;
  }

  void promptChooseAction(ShoppingList list){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text("Choose action"),
              actions: <Widget>[
                new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text("Delete"),
                    onPressed: () {
                      removeList(list.id);
                      Navigator.of(context).pop();
                    }
                ),
                new FlatButton(
                    child: new Text("Update"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      pushUpdateScreen(list);
                    }
                )
              ]
          );
        }
    );
  }

  Widget buildList() {
    return FutureBuilder(
        builder: (builder, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<ShoppingList> lists = snapshot.data;
          return new ListView.builder(
              itemBuilder: (context, index) {
                if (index < lists.length) {
                  return buildItem(lists[index]);
                } else {
                  return null;
                }
              }
          );
        },
        future: getLists()
    );
  }

  Widget buildItem(ShoppingList list) {
    return new ListTile(
      title: new Text(list.name),
      onTap: () => pushListScreen(list),
      onLongPress: () => promptChooseAction(list),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Shopping lists:")
        ),
        body: buildList(),
        floatingActionButton: new FloatingActionButton(
            onPressed: pushAddScreen,
            tooltip: "Add new item",
            child: new Icon(Icons.add)
        )
    );
  }

  void pushAddScreen() {
    final nameController = TextEditingController();
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text("Add new list")
                  ),
                  body: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new TextField(
                          autofocus: true,
                          controller: nameController,
                          decoration: new InputDecoration(
                              hintText: "Name",
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),
                        new FlatButton(
                            child: new Text("Done"),
                            onPressed: () => tryAddList(nameController)
                        )
                      ]
                  )

              );
            }
        )
    );
  }

  void pushListScreen(ShoppingList list){
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  body: new ItemsWidget(list)

              );
            }
        )
    );
  }

  void pushUpdateScreen(ShoppingList list) async {
    final nameController = TextEditingController();
    nameController.text = list.name;
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text("Update list")
                  ),
                  body: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new TextField(
                          autofocus: true,
                          controller: nameController,
                          decoration: new InputDecoration(
                              hintText: "Name",
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),
                        new FlatButton(
                            child: new Text("Done"),
                            onPressed: () => tryUpdateList(list, nameController)
                        )
                      ]
                  )
              );
            }
        )
    );
  }

}