import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Најди Стан',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // home: MyHomePage(title: 'Најди стан'),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'COURSE PAGE',
      style: optionStyle,
    ),
    MyHomePage(title: "Најди Стан"),
    Text(
      'CONTACT GFG',
      style: optionStyle,
    ),
    Text(
      'CONTACT GFG',
      style: optionStyle,
    ),
    Text(
      'CONTACT GFG',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Најди стан'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white54,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      drawer: NavDrawer(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var searchTextController = TextEditingController();
  List<FlatEntity> searchList = [];

  void _search() {
    String str = searchTextController.text;
    RequestService.query(str).then((FlatSearchResponse? response) {
      setState(() {
        print(response);
        searchList = response!.query.search;
      });
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: TextField(
                    controller: searchTextController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Location',
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: _search,
                    child: Text("Search"),
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    primary: false,
                    itemBuilder: (BuildContext context, int index) => new FlatItemWidget(searchList[index]),
                    itemCount: searchList.length,
                    shrinkWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlatItemWidget extends StatelessWidget {
  final FlatEntity _entity;

  FlatItemWidget(this._entity);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _entity.title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: SingleChildScrollView(
        child: Html(data: _entity.price.toString()),
      ),
      onTap: () {},
    );
  }
}

class RequestService {
  static Future<FlatSearchResponse?> query(String search) async {
    var response = await http.get(Uri.parse("https://myflat-d6495-default-rtdb.europe-west1.firebasedatabase.app/flats/-MxkPhgLrWLRH3bf7ocd.json"));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // var map = json.decode(response.body);
      // var listCity = map['query'];
      // var searchList = listCity['search'] as List;
      var map = json.decode(response.body);
      return FlatSearchResponse.fromJson(map);
    } else {
      print("Query failed: ${response.body} (${response.statusCode})");
      return null;
    }
  }
}

class FlatSearchResponse {
  FlatQueryResponse query;
  FlatSearchResponse({required this.query});

  factory FlatSearchResponse.fromJson(Map<String, dynamic> json) => FlatSearchResponse(query: FlatQueryResponse.fromJson(json['query']));
}

class FlatQueryResponse {
  List<FlatEntity> search;

  FlatQueryResponse({required this.search});

  factory FlatQueryResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultList = json['search'];
    List<FlatEntity> search = resultList.map((dynamic value) => FlatEntity.fromJson(value)).toList(growable: false);
    return FlatQueryResponse(search: search);
  }
}

class FlatEntity {
  String city;
  String municipality;
  int price;
  String title;

  FlatEntity({required this.city, required this.municipality, required this.price, required this.title});

  factory FlatEntity.fromJson(Map<String, dynamic> json) => FlatEntity(city: json["City"], municipality: json["Municipality"], price: json["Price"], title: json["Title"]);
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new SizedBox(
            height: 10.0,
            child: new DrawerHeader(
              child: Text(
                'Најди Стан',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(color: Colors.red
                  /*image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/images/cover.jpg'))*/),
            ),
          ),
          ListTile(
            // leading: Icon(Icons.pin_drop),
            title: Text('Skopje'),
            onTap: () => {},
          ),
          ListTile(
            // leading: Icon(Icons.pin_drop),
            title: Text('Bitola'),
            onTap: () => {
              Navigator.of(context).pop()
            },
          ),
          ListTile(
            // leading: Icon(Icons.pin_drop),
            title: Text('Kumanovo'),
            onTap: () => {
              Navigator.of(context).pop()
            },
          ),
          ListTile(
            // leading: Icon(Icons.pin_drop),
            title: Text('Prilep'),
            onTap: () => {
              Navigator.of(context).pop()
            },
          ),
          ListTile(
            // leading: Icon(Icons.pin_drop),
            title: Text('Ohrid'),
            onTap: () => {
              Navigator.of(context).pop()
            },
          ),
        ],
      ),
    );
  }
}
