import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.red, //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons
    systemNavigationBarColor: Colors.red, //bottom bar color

    systemNavigationBarIconBrightness: Brightness.dark, //bottom bar icons
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BigMoji',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'BigMoji'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  int _counter = 0;
  final myController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  final timeFormat = DateFormat('MM-dd – kk:mm');
  bool isDrag = false;
  Future<Database> database;

  createDatabase() async {
    database = openDatabase(
      // Set the path to the database.

      join(await getDatabasesPath(), 'message.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages (message TEXT, fontSize INTEGER, timestamp DEFAULT CURRENT_TIMESTAMP )",
        );
      },

      onOpen: (d) {
        //print(d.execute("select * from messages;"));

        getM();

        //print(d.query("messages").then((value) => print(value)));
      },
      version: 1,
    );
  }

  @override
  void initState() {
    super.initState();

    createDatabase();

    //   FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
    // FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: secondaryApp);

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1000000));
    controller.addListener(() {
      if (l[0].fontSize < 50) {
        setState(() {
          if (!isDrag) {
            l[0].fontSize++;
          }
        });
      }
      if (l[0].fontSize > 14) {
        if (isDrag) {
          setState(() {
            l[0].fontSize--;
          });
          if (!isDrag) {}
        }
      }
    });
    _scrollController.addListener(() {
      //  print(maxScroll);
      // double currentScroll = _scrollController.position.pixels;
      if (_scrollController.position.extentAfter < 100) {
        //  print(_scrollController.position.extentAfter );
        // print("LOAD MORE") ;

        if (!isDataEnd) {
          getM();
        }
        setState(() {
          //   items.addAll(new List.generate(42, (index) => 'Inserted $index'));
        });
      }
    });
  }

  getM() async {
    if (!isLoading) {
      await getMessages();
    }

    print("ABCD");
    setState(() {});
  }

  double fontSize = 14.0;

  bool isDataEnd = false;
  bool isLoading = false;

  int offset = 0;
  Future<List<Message>> getMessages() async {
    // Get a reference to the database.
    isLoading = true;
    final Database db = await database;

    // Query the table for all The Dogs.

    if (!isDataEnd) {
      final List<Map<String, dynamic>> maps = await db.query('messages',
          orderBy: "timestamp DESC", offset: offset, limit: 20);

      offset = offset + 20;

      if (maps.length < 20) {
        isDataEnd = true;
      }

      // Convert the List<Map<String, dynamic> into a List<Dog>.
      List.generate(maps.length, (i) {
        l.add(Message(maps[i]["message"], maps[i]["fontSize"].toDouble(),
            DateTime.parse(maps[i]["timestamp"])));
        print(maps[i]);
      });
    }

    isLoading = false;
  }

  //double height = 14.0;

  List<Message> l = [];

  String text = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("BigMoji"),
      ),
      body: Column(children: <Widget>[
        Flexible(
          child: ListView.builder(
            controller: _scrollController,

            padding: EdgeInsets.all(8.0),
            reverse: true, //To keep the latest messages at the bottom
            itemBuilder: (_, int index) {
              return Padding(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                  child: Padding(
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          child: Text(l[index].text,
                              style: TextStyle(fontSize: l[index].fontSize)),
                          padding: EdgeInsets.only(bottom: 15),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(timeFormat.format(l[index].timestamp)),
                        )
                      ],
                    ),
                    padding: EdgeInsets.only(
                        left: 20, top: 20, right: 14, bottom: 14),
                  ),
                ),
                padding: EdgeInsets.all(15),
              );

              // l[index]
            },
            itemCount: l.length,
          ),
        ),
        Divider(height: 1.0),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width - 120,
                  child: Container(
                      child: TextFormField(
                    controller: myController,
                    onChanged: (e) {
                      text = e;
                    },
                  )),
                ),
                Spacer(),
                GestureDetector(
                  onTapDown: (_) {
                    print(myController.text);
                    if (myController.text != "") {
                      Message m =
                          new Message(myController.text, 14, DateTime.now());
                      l.insert(0, m);

                      //_scrollController.jumpTo(_scrollController.position.maxScrollExtent + 90);
//               await insertDog(m);

                      setState(() {});
                      controller.forward();
                    }
                  },
                  onTapUp: (_) {
                    if (controller.status == AnimationStatus.forward) {
                      controller.stop();
                      fontSize = 14;
                      print("end");
                    }
                    insertDog();
                  },
                  onVerticalDragStart: (_) {
                    isDrag = true;
                  },
                  onVerticalDragEnd: (_) {
                    isDrag = false;
                    if (controller.status == AnimationStatus.forward) {
                      controller.stop();
                    }
                    insertDog();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(18))),
                    child: Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> insertDog() async {
    // Get a reference to the database.

    print(myController.text);
    if (myController.text != "") {
      myController.text = "";

      Message dog = l[0];
      final Database db = await database;

      print(dog.toMap().toString());
      var s = await db.insert(
        'messages',
        dog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print(s);
    }
  }
}

class Message {
  String text;
  double fontSize;
  DateTime timestamp;

  Message(this.text, this.fontSize, this.timestamp);

  Map<String, dynamic> toMap() {
    return {
      'message': text,
      'fontSize': fontSize,
    };
  }
}
