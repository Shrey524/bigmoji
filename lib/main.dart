import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blue, //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons
    systemNavigationBarColor: Colors.blue, //bottom bar color

    systemNavigationBarIconBrightness: Brightness.dark, //bottom bar icons
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false
,
      title: 'BigMoji',
      theme: ThemeData(

        primarySwatch: Colors.blue,
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

class _MyHomePageState extends State<MyHomePage>   with SingleTickerProviderStateMixin {
  AnimationController controller;
  int _counter = 0;
  final myController = TextEditingController();
  ScrollController _scrollController = new ScrollController();

    Future<Database> database;


  createDatabase() async{


       database =   openDatabase(
      // Set the path to the database.


      join(await getDatabasesPath(), 'message.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages (message TEXT, fontSize INTEGER, timestamp DEFAULT CURRENT_TIMESTAMP )",
        );
      },

        onOpen: (d){

          //print(d.execute("select * from messages;"));

          getM();


          print(d.query("messages").then((value) => print(value)));

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
        AnimationController(vsync: this, duration: Duration(seconds: 10));
    controller.addListener(() {
       setState(() {

        l[l.length-1].fontSize++;
      });
    });
  }


  getM() async {
    List n   = await getMessages();


    setState(() {

    });
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 90);

  }

  double fontSize = 14.0;


  Future<List<Message>> getMessages() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('messages');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
      List.generate(maps.length, (i) {


        l.add(Message(maps[i]["text"], maps[i]["fontSize"].toDouble()));
      print(maps[i]);

    });
  }



  //double height = 14.0;

  List<Message> l = [];

String text = "";
  @override
  Widget build(BuildContext context) {

    return   Scaffold(
      appBar: AppBar(
        title: Text("BigMoji"),
      ),
      body: Column(children: <Widget>[

        Flexible(
          child: ListView.builder(
            controller: _scrollController,

            padding: EdgeInsets.all(8.0),
            reverse: false, //To keep the latest messages at the bottom
            itemBuilder: (_, int index) {

              if(index == l.length-1)
                {
                  return Padding(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(33, 150, 243, 0.2),

                          borderRadius: BorderRadius.all(Radius.circular(18))
                      ),

                      child:Padding(
                        child: Text(l[index].text, style: TextStyle(
                            fontSize: l[index].fontSize
                        ),),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                    padding: EdgeInsets.all(15),
                  );
                }

              return Padding(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(33, 150, 243, 0.2),

                      borderRadius: BorderRadius.all(Radius.circular(18))
                  ),

                  child:Padding(
                    child: Text(l[index].text, style: TextStyle(
                        fontSize: l[index].fontSize
                    ),),
                    padding: EdgeInsets.all(20),
                  ),
                ),
                padding: EdgeInsets.all(15),
              );

              // l[index]
            },
            itemCount: l.length,
          ),),
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
                  width: MediaQuery.of(context).size.width-120,
                  child: Container(
                      child:  TextFormField(
                        controller: myController,
                        onChanged: (e){
                          text = e;
                        },
                      )

                  ),
                ),
            Spacer(),
            GestureDetector(

             onTapDown: (_)   {

               Message m = new Message(text, 14);
               l.add(m);
               print("SSS");

               _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 90);
//               await insertDog(m);

               myController.text = "";
               setState(() {

               });
                controller.forward();},

              onTapUp: (_) {
                if (controller.status == AnimationStatus.forward) {
                  controller.stop();
                  fontSize = 14;
 insertDog();

                }
              },
            child: Container(height: 50,width: 50, decoration: BoxDecoration(
    color: Colors.blue,

    borderRadius: BorderRadius.all(Radius.circular(18))
    ),child: Center(
              child: Icon(Icons.send, color: Colors.white,),
            ),),
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

    Message dog  = l[l.length-1];
    final Database db = await database;


    await db.insert(
      'messages',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }









}



class Message{

  String text;
  double fontSize ;

  Message(this.text, this.fontSize);



  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'fontSize': fontSize,

    };
  }

}
