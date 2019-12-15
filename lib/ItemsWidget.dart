import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';
import 'package:flutter_app/item.dart';
import 'package:flutter_app/shoppingList.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'serverCom.dart';

class ItemsWidget extends StatefulWidget {
  final ShoppingList list;

  ItemsWidget(this.list);

  @override
  createState() => new ItemsWidgetState(list);
}

class ItemsWidgetState extends State<ItemsWidget> {
  DatabaseProvider dbProvider = new DatabaseProvider();
  ShoppingList list;

  ItemsWidgetState(this.list);

  ServerCom serverCom = new ServerCom();
  var subscription;

  @override
  initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      //sendData();
    });
  }

  Future<List<Item>> getItems() async {
    return await dbProvider.getItems(this.list);
  }

  void addItem(Item item) async {
    await dbProvider.insertItem(item);
    if(await checkConnection()) {
      await serverCom.addItem(item);
    }
    setState(() {});
  }

  void tryAddItem(TextEditingController nameController, TextEditingController priceController){
    if(nameController.text.isEmpty || priceController.text.isEmpty){
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
      addItem(new Item(id: -1, list_id: this.list.id, price: int.parse(priceController.text), name: nameController.text));
      Navigator.pop(context);
    }
  }

  void removeItem(int id) async {
    if(await checkConnection()) {
      await dbProvider.deleteItem(id);
      await serverCom.deleteItem(id);
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

  void updateItem(Item item) async {
    if(await checkConnection()) {
      await dbProvider.updateItem(item);
      await serverCom.updateItem(item);
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

  void tryUpdateItem(Item item, TextEditingController nameController, TextEditingController priceController){
    if(nameController.text.isEmpty || priceController.text.isEmpty){
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
      updateItem(new Item(id: item.id, list_id: list.id, price: int.parse(priceController.text), name: nameController.text));
      Navigator.pop(context);
    }
  }

  void sendData() async {
    List<Item> items = await getItems();
    serverCom.sendItemsData(items);
  }

  Future<bool> checkConnection() async {
    var conres = await Connectivity().checkConnectivity();
    if(conres == ConnectivityResult.wifi){
      return true;
    }
    return false;
  }

  void showItemDetails(Item item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            contentPadding: const EdgeInsets.all(16.0),
            children: <Widget>[
              new Text("id: " + item.id.toString()),
              new Text("Name: " + item.name),
              new Text("Price: " + item.price.toString())
            ],

          );
        }
    );
  }

  void promptChooseAction(Item item){
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
                      removeItem(item.id);
                      Navigator.of(context).pop();
                    }
                ),
                new FlatButton(
                    child: new Text("Update"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      pushUpdateScreen(item);
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
          List<Item> items = snapshot.data;
          return new ListView.builder(
              itemBuilder: (context, index) {
                if (index < items.length) {
                  return buildItem(items[index]);
                } else {
                  return null;
                }
              }
          );
        },
        future: getItems()
    );
  }

  Widget buildItem(Item item) {
    return new ListTile(
      title: new Text(item.name),
      onTap: () => showItemDetails(item),
      onLongPress: () => promptChooseAction(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(list.name)
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
    final priceController = TextEditingController();
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text("Add new item")
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
                        new TextField(
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          controller: priceController,
                          decoration: new InputDecoration(
                              hintText: "Price",
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),
                        new FlatButton(
                            child: new Text("Done"),
                            onPressed: () => tryAddItem(nameController, priceController)
                        )
                      ]
                  )

              );
            }
        )
    );
  }

  void pushUpdateScreen(Item item) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    nameController.text = item.name;
    priceController.text = item.price.toString();
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text("Update item")
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
                        new TextField(
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          controller: priceController,
                          decoration: new InputDecoration(
                              hintText: "Price",
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),
                        new FlatButton(
                            child: new Text("Done"),
                            onPressed: () => tryUpdateItem(item, nameController, priceController)
                        )
                      ]
                  )
              );
            }
        )
    );
  }
}