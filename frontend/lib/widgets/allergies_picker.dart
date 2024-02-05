import 'package:flutter/material.dart';
import '../dto/item_allergies_enum.dart';

class AllergiesPicker extends StatefulWidget {
  final List<ItemAllergy>? initialAllergies;

  const AllergiesPicker({super.key, this.initialAllergies});

  @override
  State<StatefulWidget> createState() => _AllergiesPickerState();
}

class _AllergiesPickerState extends State<AllergiesPicker> {
  List<ItemAllergy> _allergies = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAllergies != null) {
      _allergies = widget.initialAllergies!;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _allergies = [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose allergies'),
      content: IntrinsicHeight(
          child: Column(
        children: ItemAllergy.values
            .map((e) => ListTile(
                  title: Text(e.name),
                  leading: Checkbox(
                    value: _allergies.contains(e),
                    onChanged: (bool? isChosen) {
                      setState(() {
                        if (isChosen != null && isChosen) {
                          _allergies.add(e);
                        }
                        if (isChosen != null && !isChosen) {
                          _allergies.remove(e);
                        }
                      });
                    },
                  ),
                ))
            .toList(growable: false),
      )),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(context, _allergies),
            child: const Text('OK'))
      ],
    );
  }
}
