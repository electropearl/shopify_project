import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopify Inventory Tracking',
      theme: ThemeData(
        fontFamily: 'Raleway',
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(title: 'INVENTORY'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fireStoreReference = FirebaseFirestore.instance;
  final List<String> options = <String>['Add', 'Delete', 'Update'];
  final List<String> options2 = <String>['Create Warehouse'];

//intialize varables
  String error = " ";
  String itemName = "";
  int? groupID = 0;
  int? locationID = 0;
  String? docID = "";
  String location = "";
  String price = "";
  String warehouse = "";
  String state = "";
  String city = "";

  // Creates a refrence object of a collection in database //
  CollectionReference oEvents = FirebaseFirestore.instance.collection('Item');

  //add item to DB
  Future? addItem(String itemName, int? groupID, int? locationID,
      String location, String price) {
    //needs to be changed to it grabs data from database quick fix for now. This could happen inside of the textfields
    Map<int, String> groups = {
      0: "SHOES",
      1: "SHIRTS",
      2: "PANTS",
      3: "HATS",
    };

    try {
      // This is where the magic happens, the app takes the user input and assigns it to local variables which are then passed to the collection and creates a document //
      return fireStoreReference
          .collection("Item")
          .doc()
          .set({
            'location': location,
            'name': itemName,
            'locationID': locationID,
            'groupID': groupID,
            'price': price,
            'groupname': groups[groupID]
          })
          .then((value) => print("Item Added"))
          // ignore: avoid_print
          .catchError((error) => print("Failed to add item: $error"));
    } catch (e) {
      Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 14.0),
      );
      return null;
    }
  }

  //popup for creating ware house
  Widget _buildPopupDialogAddWarehouse(BuildContext context) {
    final addForm = GlobalKey<FormState>();
    // This variable is being used. I have no idea why it thinks it's not //
    int? newValue = 0;
    return AlertDialog(
      title: const Text('Warehouse Creation'),
      // Creates a form which has a key that gives it an identifier //
      content: Form(
        key: addForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // One of the fields that takes user input and assigns it to local var //
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing Warehouse Name";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => warehouse = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Warehouse Name',
                  labelText: 'Warehouse',
                )),
            // One of the fields that takes user input and assigns it to local var //

            // One of the fields that takes user input and assigns it to local var //
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing State";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => state = val);
                },
                decoration: const InputDecoration(
                  hintText: 'State',
                  labelText: 'State',
                )),
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing City";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => city = val);
                },
                decoration: const InputDecoration(
                  hintText: 'City',
                  labelText: 'City',
                )),

            Padding(
              // button that submits the field once filled using a validator to make sure the right info is entered //
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 100, 226, 109)),
                onPressed: () {
                  if (addForm.currentState!.validate()) {
                    var results = addWarehouse(warehouse, state, city);

                    if (results == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => submitError(),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Button that closes add / delete menu //
        TextButton(
          style: TextButton.styleFrom(
            primary: const Color.fromARGB(
                255, 22, 20, 20), // This is a custom color variable
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

//add a warehouse
  Future? addWarehouse(String warehouse, String state, String city) async {
    //gets index of locations so location id will increment so no warehouse has same id
    final QuerySnapshot qSnap =
        await fireStoreReference.collection('locations').get();
    final int count = qSnap.docs.length;

    try {
      // This is where the magic happens, the app takes the user input and assigns it to local variables which are then passed to the collection and creates a document //
      return fireStoreReference
          .collection("locations")
          .doc()
          .set({
            'city': city,
            'locationID': FieldValue.increment(count),
            'state': state,
            'warehouse': warehouse
          })
          .then((value) => print("Warehouse Created"))
          .catchError((error) => print("Failed to add Warehouse: $error"));
    } catch (e) {
      Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 14.0),
      );
      return null;
    }
  }

// This function deletes the item by docID //
  Future? delUser(String itemName, int? groupID) async {
    try {
      return fireStoreReference
          .collection("Item")
          .doc(docID)
          .delete()
          .then((value) => print("Item Deleted"))
          .catchError((error) => print("Failed to add item: $error"));
    } catch (e) {
      Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 14.0),
      );
      return null;
    }
  }

//gets update item input
  Widget _buildPopupDialogUpdate(BuildContext context) {
    final addForm = GlobalKey<FormState>();
    // This variable is being used. I have no idea why it thinks it's not //
    int? newValue = 0;
    return AlertDialog(
      title: const Text('Update Item'),
      // Creates a form which has a key that gives it an identifier //
      content: Form(
        key: addForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // One of the fields that takes user input and assigns it to local var //
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Item').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    hint: const Text("Choose Item"),
                    validator: (value) => value == null ? 'No Entry' : null,
                    onSaved: (newValue) => docID,
                    onChanged: (value) {
                      setState(() {
                        docID = value;
                        newValue = value as int?;
                      });
                    },
                    items: snapshot.data?.docs.map((DocumentSnapshot document) {
                      String gn = document['groupname'];
                      String en = document['name'];
                      return DropdownMenuItem<String>(
                          value: document.id,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0)),
                            height: 50.0,
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                            child: Text(gn + " - " + en),
                          ));
                    }).toList(),
                  );
                }),
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing item name";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => itemName = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Item Name',
                  labelText: 'Name',
                )),
            // One of the fields that takes user input and assigns it to local var //

            // One of the fields that takes user input and assigns it to local var //
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing price";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => price = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Price of Item',
                  labelText: 'Item Price',
                )),
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing location";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => location = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Enter the location...',
                  labelText: 'Item Location',
                )),

            // This is a streambuilder that querys the database for all documents in the groups collection //
            // It then takes those ducments and populates a drop down menu with them so the user can choose what group the event belongs to //
            // For detailed info on how streambuilder works see setup.dart //
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return DropdownButtonFormField<int>(
                  hint: const Text("Group"),
                  validator: (value) => value == null ? 'No Entry' : null,
                  onSaved: (newValue) => groupID,
                  onChanged: (value) {
                    setState(() {
                      groupID = value;
                      newValue = value;
                    });
                  },
                  items: snapshot.data?.docs.map((DocumentSnapshot document) {
                    return DropdownMenuItem<int>(
                        value: document["groupID"],
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0)),
                          height: 50.0,
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                          child: Text(document['groupname']),
                        ));
                  }).toList(),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('locations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return DropdownButtonFormField<int>(
                  hint: const Text("Location"),
                  validator: (value) => value == null ? 'No Entry' : null,
                  onSaved: (newValue) => locationID,
                  onChanged: (value) {
                    setState(() {
                      locationID = value;
                      newValue = value;
                    });
                  },
                  items: snapshot.data?.docs.map((DocumentSnapshot document) {
                    return DropdownMenuItem<int>(
                        value: document["locationID"],
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0)),
                          height: 50.0,
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                          child: Text(document['warehouse']),
                        ));
                  }).toList(),
                );
              },
            ),
            Padding(
              // button that submits the field once filled using a validator to make sure the right info is entered //
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 100, 226, 109)),
                onPressed: () {
                  if (addForm.currentState!.validate()) {
                    var results = updateUser(
                        itemName, groupID, locationID, location, price);

                    if (results == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => submitError(),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Button that closes add / delete menu //
        TextButton(
          style: TextButton.styleFrom(
            primary: const Color.fromARGB(
                255, 22, 20, 20), // This is a custom color variable
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

//updates the item
  Future? updateUser(String itemName, int? groupID, int? locationID,
      String location, String price) async {
    Map<int, String> groups = {
      0: "SHOES",
      1: "SHIRTS",
      2: "PANTS",
      3: "HATS",
    };
    try {
      return fireStoreReference
          .collection("Item")
          .doc(docID)
          .update({
            'location': location,
            'name': itemName,
            'locationID': locationID,
            'groupID': groupID,
            'price': price,
            'groupname': groups[groupID]
          })
          .then((value) => print("Item Deleted"))
          .catchError((error) => print("Failed to add item: $error"));
    } catch (e) {
      Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 14.0),
      );
      return null;
    }
  }

//add item input
  Widget _buildPopupDialogAdd(BuildContext context) {
    final addForm = GlobalKey<FormState>();
    // This variable is being used. I have no idea why it thinks it's not //
    int? newValue = 0;
    return AlertDialog(
      title: const Text('Add Item'),
      // Creates a form which has a key that gives it an identifier //
      content: Form(
        key: addForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // One of the fields that takes user input and assigns it to local var //
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing item name";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => itemName = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Item Name',
                  labelText: 'Name',
                )),
            // One of the fields that takes user input and assigns it to local var //
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing price";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => price = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Price of Item',
                  labelText: 'Item Price',
                )),
            TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Missing location";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => location = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Enter the location...',
                  labelText: 'Item Location',
                )),

            // This is a streambuilder that querys the database for all documents in the groups collection //
            // It then takes those ducments and populates a drop down menu with them so the user can choose what group the event belongs to //
            // For detailed info on how streambuilder works see setup.dart //
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return DropdownButtonFormField<int>(
                  hint: const Text("Group"),
                  validator: (value) => value == null ? 'No Entry' : null,
                  onSaved: (newValue) => groupID,
                  onChanged: (value) {
                    setState(() {
                      groupID = value;
                      newValue = value;
                    });
                  },
                  items: snapshot.data?.docs.map((DocumentSnapshot document) {
                    return DropdownMenuItem<int>(
                        value: document["groupID"],
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0)),
                          height: 50.0,
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                          child: Text(document['groupname']),
                        ));
                  }).toList(),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('locations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return DropdownButtonFormField<int>(
                  hint: const Text("Location"),
                  validator: (value) => value == null ? 'No Entry' : null,
                  onSaved: (newValue) => locationID,
                  onChanged: (value) {
                    setState(() {
                      locationID = value;
                      newValue = value;
                    });
                  },
                  items: snapshot.data?.docs.map((DocumentSnapshot document) {
                    return DropdownMenuItem<int>(
                        value: document["locationID"],
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0)),
                          height: 50.0,
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                          child: Text(document['warehouse']),
                        ));
                  }).toList(),
                );
              },
            ),
            Padding(
              // button that submits the field once filled using a validator to make sure the right info is entered //
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 100, 226, 109)),
                onPressed: () {
                  if (addForm.currentState!.validate()) {
                    var results =
                        addItem(itemName, groupID, locationID, location, price);

                    if (results == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => submitError(),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Button that closes add / delete menu //
        TextButton(
          style: TextButton.styleFrom(
            primary: const Color.fromARGB(
                255, 22, 20, 20), // This is a custom color variable
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

//delete form
  Widget _buildPopupDialogDelete(BuildContext context) {
    final delForm = GlobalKey<FormState>();
    String? newValue = "";
    return AlertDialog(
      title: const Text('Delete Item'),
      // Creates form so the app can take user submission //
      content: Form(
        // unique identifier //
        key: delForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // There are no text fields because all they need to do is choose and event and then press submit to confirm deletion
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Item').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    validator: (value) => value == null ? 'No Entry' : null,
                    onSaved: (newValue) => docID,
                    onChanged: (value) {
                      setState(() {
                        docID = value;
                        newValue = value;
                      });
                    },
                    items: snapshot.data?.docs.map((DocumentSnapshot document) {
                      String gn = document['groupname'];
                      String en = document['name'];
                      return DropdownMenuItem<String>(
                          value: document.id,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0)),
                            height: 50.0,
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                            child: Text(gn + " - " + en),
                          ));
                    }).toList(),
                  );
                }),
            Padding(
              // Button for deletion confirmation //
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 100, 226, 109)),
                onPressed: () {
                  if (delForm.currentState!.validate()) {
                    delUser(itemName, groupID);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Button for closing //
        TextButton(
          style: TextButton.styleFrom(
            primary: const Color.fromARGB(
                255, 0, 0, 0), // This is a custom color variable
          ),
          onPressed: () {
            try {
              Navigator.of(context).pop();
            } catch (e) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  //update item

  // This is a function that pushes an error on the screen if all the fields are messed up in the add form //
  submitError() {
    return AlertDialog(
      title: const Text('Submission Error'),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text('Please make sure all fields are filled'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Okay'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

//builds cards
  Widget _buildHomeItem(BuildContext context, DocumentSnapshot document) {
    //String docID = document.id;

    // Function that creates popup for extra info //
    infoPage() {
      return AlertDialog(
        title: Text(document["name"]),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("Group: " + document["groupname"] + "\n"),
              Text("Price: " + document["price"] + "\n"),
              Text("Location: " + document["location"] + "\n"),
              //Text("Warehouse: " + document["warehouse"] + "\n"),
              //Text("Contact Organizer: " + document["Organizer"] + "\n"),
            ],
          ),
        ),
      );
    }

    // Builds the items on homepage creates a containers, centers them, creates a card in that container //
    // Than puts a column in each card that you can fill with text widgets //
    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 100, 226, 109),
          backgroundBlendMode: BlendMode.srcOver,
          border: Border.all(
              color: const Color.fromARGB(255, 204, 204, 204),
              width: 10,
              style: BorderStyle.solid)),
      child: Center(
        child: Card(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                      child: Text(
                    document['name'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text(document['price']))),
              Row(
                // Extra info button that calls function infopage //
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => infoPage(),
                        ),
                        icon: const Icon(Icons.info),
                        //color: maroon,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          elevation: 6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2));
    Timer(const Duration(seconds: 1), () {});
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(
            widget.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontFamily: 'RobotoMono'),
          ),
          backgroundColor: const Color.fromARGB(255, 100, 226, 109),
          leading: PopupMenuButton<String>(
            icon: const Icon(
              Icons.shopping_bag,
              color: Colors.white,
            ),
            color: Colors.white,
            itemBuilder: (BuildContext context) => options.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList(),
            onSelected: (String value) {
              if (value == 'Add') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogAdd(context),
                );
              } else if (value == "Delete") {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogDelete(context),
                );
              } else if (value == "Update") {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogUpdate(context),
                );
              }
            },
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.warehouse,
                color: Colors.white,
              ),
              color: Colors.white,
              itemBuilder: (BuildContext context) =>
                  options2.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
              onSelected: (String value) {
                if (value == 'Create Warehouse') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialogAddWarehouse(context),
                  );
                }
              },
            )
          ]),
      body: StreamBuilder<QuerySnapshot>(
          // Querys database for information that will be used in streambuidler from database //
          stream: FirebaseFirestore.instance.collection('Item').snapshots(),
          // Builder for the steambuilder, builds the items that will be displayed //
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading");
            } else {
              // Using listview to display the contents //
              return ListView.builder(
                // How big the items can be //
                itemExtent: 250,
                // How many items there will be //
                itemCount: snapshot.data?.docs.length,
                // Method that will be used to build items //
                itemBuilder: (context, index) =>
                    _buildHomeItem(context, snapshot.data!.docs[index]),
              );
            }
          }),
    );
  }
}
