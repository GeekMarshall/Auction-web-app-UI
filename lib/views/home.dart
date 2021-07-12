import 'dart:convert';
import 'package:auction_ui3/views/listings.dart';
import 'package:auction_ui3/views/login.dart';
import 'package:auction_ui3/views/register.dart';
import 'package:auction_ui3/views/search_results.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  // final user;
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool globalStatus = false;
  List<dynamic> placed = [];
  List<dynamic> won = [];
  List<dynamic> subList = [];

  Future checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var localStatus = prefs.getBool('status');
    print('$localStatus');
    if (localStatus == true) {
      setState(() {
        globalStatus = true;
      });
    }
  }

  getBidResults() {
    Future.delayed(Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var user = prefs.getString('user').toString();
      var res1 = await http.get(Uri.parse(
          'https://auction-server2.herokuapp.com/api/get-bids/$user'));
      var res2 = await http
          .get(Uri.parse('https://auction-server2.herokuapp.com/api/results'));
      var decode1 = jsonDecode(res1.body);
      var decode2 = jsonDecode(res2.body);

      for (var i in decode2) {
        if (i['winner'] == user) {
          subList.add(i);
        }
        setState(() {
          placed = decode1['result'];
          won = subList;
        });
      }
    });
  }

  @override
  void initState() {
    getBidResults();
    checkStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // THIS IS THE APPBAR
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.teal[900],
          shadowColor: Colors.white,
          flexibleSpace: Center(
            child: Text(
              "KeiBai",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 50),
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Navbar(
                status: globalStatus,
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: globalStatus
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Bids Placed',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50),
                            ),
                            Text('Bids Won',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 50)),
                          ],
                        )
                      : Container()),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: globalStatus
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: placed.isEmpty
                                      ? LinearProgressIndicator()
                                      : ListView.builder(
                                          itemCount: placed.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child: Text(placed[index]
                                                    ['assetName']));
                                          }),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: won.isEmpty
                                      ? LinearProgressIndicator()
                                      : ListView.builder(
                                          itemCount: won.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                                child:
                                                    Text(won[index]['name']));
                                          }),
                                ),
                              ])
                        : Text(
                            'SIGMA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 80),
                          )),
              ),
              // FOOTER
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                color: Colors.teal[300],
                child: Center(
                  child: Text(
                    'KeiBai Inc.',
                    style: TextStyle(fontSize: 30, color: Colors.white),
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

// NAVBAR CLASS
class Navbar extends StatefulWidget {
  final bool status;
  const Navbar({Key? key, required this.status}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  TextEditingController _searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // THIS IS THE LEFT SIDE OF THE NAVBAR
          Container(
              width: 500,
              margin: EdgeInsets.only(left: 30),
              child: Row(children: [
                Expanded(
                    child: TextField(
                  controller: _searchText,
                  decoration: InputDecoration(hintText: 'Search...'),
                )),
                IconButton(
                    onPressed: () async {
                      var res = await http.get(Uri.parse(
                          'https://auction-server2.herokuapp.com/api/search/${_searchText.text}'));
                      if (res.statusCode == 223) {
                        print(res.body);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SearchListings(initString: res.body)));
                        _searchText.clear();
                      } else {
                        showAlertDialogBoxSearch(context, _searchText);
                      }
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ))
              ])),
          // THIS IS THE RIGHT SIDE OF NAVBAR
          widget.status
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Listings()));
                            print('pressed listings');
                          },
                          child: Text('Listings',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                            print('pressed logout');
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('status', false);
                          },
                          child: Text("Logout",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20))),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Listings()));
                            print('pressed listings');
                          },
                          child: Text('Listings',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()));
                            print('pressed register');
                          },
                          child: Text('Register',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                            print('pressed login');
                          },
                          child: Text('Login',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20))),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}

showAlertDialogBoxSearch(
    BuildContext context, TextEditingController controller) {
  Widget submit = ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        controller.clear();
      },
      child: Text("OK"));

  AlertDialog alert = AlertDialog(
    title: Text('Not Found'),
    content: Text('Sorry, there are no such assets.'),
    actions: [submit],
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}
