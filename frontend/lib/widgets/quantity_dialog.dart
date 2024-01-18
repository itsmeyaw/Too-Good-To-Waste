import 'package:flutter/material.dart';

class QuantityNumber extends StatefulWidget {
  var quantityNum = _QuantityNumberState().pressedAttentionIndex;

  QuantityNumber({Key? key}) : super(key: key);
  @override
  _QuantityNumberState createState() => _QuantityNumberState();
}

class _QuantityNumberState extends State<QuantityNumber> {
  int pressedAttentionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select List Items'),
      ),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          final pressAttention = pressedAttentionIndex == index;
          return Container(
            color: pressAttention ? Colors.blue : Colors.white,
            child: ListTile(
              onTap: () => setState(() => pressedAttentionIndex = index),
              title: Text(
                '$index',
                // style: (this == pressedAttentionIndex)
                //     ? TextStyle(
                //         fontSize: 18,
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold,
                //       )
                //     : TextStyle(fontSize: 20)
              ),
            ),
          );
        },
      ),
    );
  }
}
