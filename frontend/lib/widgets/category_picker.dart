import 'package:flutter/material.dart';
import '../dto/item_category_enum.dart';

class CategoryPicker extends StatefulWidget {
  final ItemCategory? initialCategory;
  final bool isClear;

  const CategoryPicker({super.key, this.initialCategory, this.isClear = false});

  @override
  State<StatefulWidget> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  ItemCategory? _chosenCategory;

  @override
  void initState() {
    super.initState();
    _chosenCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Category'),
      content: IntrinsicHeight(
        child: Column(
          children: ItemCategory.values
              .map((e) => ListTile(
                    title: Text(e.name),
                    leading: Radio<ItemCategory>(
                      value: e,
                      groupValue: _chosenCategory,
                      onChanged: (ItemCategory? value) {
                        setState(() {
                          _chosenCategory = value;
                        });
                      },
                    ),
                  ))
              .toList(growable: false),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: widget.isClear ? const Text('Clear') : const Text('Close')),
        TextButton(
            onPressed: () => Navigator.pop(context, _chosenCategory),
            child: const Text('OK'))
      ],
    );
  }
}
