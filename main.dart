import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = [
  DetailPage(),
  DetailPage(),
  DetailPage(),
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
        title: const Text('Icons'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Maison',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Hôtel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.villa),
            label: 'Villa',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<String>> _futureHouseNames;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _futureHouseNames = fetchDataFromMySQL();
    _futureHouseNames.then((_) {
      setState(() {
        _isConnected = true;
      });
    }).catchError((error) {
      print('Erreur de connexion: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
      ),
      body: _isConnected
          ? Column(
              children: [
                const Text("Vous êtes connecté !"),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: _futureHouseNames,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur de chargement des données'));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(snapshot.data![index]),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}


class ItemDetailPage extends StatelessWidget {
  final House item;

  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de ${item.name}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.image),
            const SizedBox(height: 20.0),
            Text('Contenu de ${item.name}'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                print('Réservation!!');
              },
              child: const Text('Réserver'),
            ),
          ],
        ),
      ),
    );
  }
}

class House {
  final String name;
  final String image;

  House({required this.name, required this.image});
}

Future<List<String>> fetchDataFromMySQL() async {
  final conn = await MySqlConnection.connect(
    ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      password: 'root',
      db: 'rentfr',
    ),
  );
  print("Vous êtes connecté !");

  var houseNames = <String>[];

  try {
    var results = await conn.query("SELECT id_bien,nom_bien,descriptif FROM biens");
    for (var row in results) {
      houseNames.add(row['id_bien'].toString());
      houseNames.add(row['nom_bien'].toString());
      houseNames.add(row['descriptif'].toString());
    }
  } finally {
    await conn.close();
  }

  return houseNames;
}



