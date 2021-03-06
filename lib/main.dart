import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());
late List<City> futureCities = [];
late List<FlatEntity> futureFlatEntities = [];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Flutter Code Sample';
  @override
  Widget build(BuildContext context) {
    fetchCity().then((value) => {
          futureCities = value,
          // futureCities.forEach((element) {
          //   print(element.name);
          // })
        });
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

  void _search() async {
    String str = searchTextController.text;
    // fetchFlat().then((value) => {
    //       futureFlatEntities = value,
    //       searchList = value,

    searchList = await fetchFlat();
    setState(() {
      searchList = searchList;
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

class FlatEntity {
  String city;
  String municipality;
  int price;
  String title;

  FlatEntity({required this.city, required this.municipality, required this.price, required this.title});

  factory FlatEntity.fromJson(Map<String, dynamic> json) => FlatEntity(city: json["City"], municipality: json["Municipality"], price: json["Price"], title: json["Title"]);
}

class City {
  final String name;
  const City({required this.name});
  factory City.fromJson(Map<String, dynamic> json) {
    return City(name: json['name']);
  }
}

Future<http.Response> fetchCities() {
  return http.get(Uri.parse("https://myflat-d6495-default-rtdb.europe-west1.firebasedatabase.app/cities.json"));
}

Future<http.Response> fetchFlats() {
  return http.get(Uri.parse("https://myflat-d6495-default-rtdb.europe-west1.firebasedatabase.app/flats.json"));
}

Future<List<City>> fetchCity() async {
  final response = await http.get(Uri.parse('https://myflat-d6495-default-rtdb.europe-west1.firebasedatabase.app/cities.json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Iterable l = json.decode(response.body);
    List<City> cities = List<City>.from(l.map((model) => City.fromJson(model)));
    return cities;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load city');
  }
}

Future<List<FlatEntity>> fetchFlat() async {
  final response = await http.get(Uri.parse('https://myflat-d6495-default-rtdb.europe-west1.firebasedatabase.app/flats.json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Iterable l = json.decode(response.body);
    List<FlatEntity> flats = List<FlatEntity>.from(l.map((model) => FlatEntity.fromJson(model)));
    return flats;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load flats');
  }
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new SizedBox(
            height: 65,
            child: new DrawerHeader(
              child: Text(
                'Најди Стан',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(color: Colors.red
                  /*image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/images/cover.jpg'))*/),
            ),
          ),
          for (var city in futureCities)
            ListTile(
              // leading: Icon(Icons.pin_drop),
              title: Text(city.name),
              onTap: () => {},
            )
        ],
      ),
    );
  }
}
