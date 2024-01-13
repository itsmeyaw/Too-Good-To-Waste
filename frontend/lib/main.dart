import 'package:firebase_core/firebase_core.dart';
import 'package:tooGoodToWaste/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/pages/Account.dart';
import 'package:tooGoodToWaste/pages/AddInventory.dart';
import 'package:tooGoodToWaste/pages/Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Too Good To Waste',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Too Good To Waste'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _activePage = 0;

  // Called when setState is called
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [],
      ),
      body: <Widget>[
        const Home(),
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Inventory',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
        const AccountPage()
      ].map((e) => Container(
        padding: const EdgeInsets.all(10),
        child: e
      )).toList()[_activePage],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _activePage = index;
          });
        },
        selectedIndex: _activePage,
        destinations: const <Widget>[
          NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home'
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.inventory_2),
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Inventory'
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outline),
              label: 'Account'
          )
        ]
      ),
      floatingActionButton: _activePage == 1 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddInventoryPage()));
        },
        tooltip: 'Add new item',
        child: const Icon(Icons.add),
      ) : null, // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
