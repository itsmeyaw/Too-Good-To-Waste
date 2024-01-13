import 'package:flutter/material.dart';
import 'package:frontend/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiseFood',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'WiseFood'),
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
      ),
      body: <Widget>[
        Home(),
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
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
      ].map((e) => Container(
        child: e,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
