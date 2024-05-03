import 'package:flutter/material.dart';

String horseUrl = 'https://i.stack.imgur.com/Dw6f7.png';
String cowUrl = 'https://i.stack.imgur.com/XPOr3.png';
String camelUrl = 'https://i.stack.imgur.com/YN0m7.png';
String sheepUrl = 'https://i.stack.imgur.com/wKzo8.png';
String goatUrl = 'https://i.stack.imgur.com/Qt4JP.png';

class BodyWidget extends StatelessWidget {
  var category;

  BodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(horseUrl),
            ),
            title: const Text('Meat'),
            subtitle: const Text('A strong animal'),
            onTap: () {
              category = 'Meat';
              //Navigator.pop(context, category);
            },
            selected: true,
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage("assets/category/meat.png"),
            ),
            title: const Text('Milk Product'),
            subtitle: const Text('Provider of milk'),
            onTap: () {
              category = 'Milk Product';
              //Navigator.pop(context, category);
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(camelUrl),
            ),
            title: const Text('Seafood'),
            subtitle: const Text('Comes with humps'),
            onTap: () {
              category = 'Seafood';
              //Navigator.pop(context, category);
            },
            enabled: false,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(sheepUrl),
            ),
            title: const Text('Fruits'),
            subtitle: const Text('Provides wool'),
            onTap: () {
              category = 'Fruits';
              //Navigator.pop(context, category);
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(goatUrl),
            ),
            title: const Text('Vegetables'),
            subtitle: const Text('Some have horns'),
            onTap: () {
              category = 'Vegetables';
              //Navigator.pop(context, category);
            },
          ),
        ],
      ),
    );
  }
}
