import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DataPicker extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var expiredate;
  //DataPicker({Key key}) : super(key: key);
  DataPicker({Key? key, required this.getdatePicker}) : super(key: key);
  final ValueChanged<int> getdatePicker;

  @override
  _DataPickerState createState() {
    return _DataPickerState(expiredate);
  }
}

class _DataPickerState extends State<DataPicker> {
  DateTime selectedDate = DateTime.now();
  //List foodDate = ['', '', -1, -1, '', -1, -1.0, ''];
  int expireDate = -1;
  ValueChanged<int> getdatePicker(int expireDate) {
   // TODO: implement getdatePicker
   //return expireDate;
   throw UnimplementedError();
 }

  _DataPickerState(getdatePicker);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ElevatedButton.icon(
          onPressed: () {
            showDatePicker();
            //return expireDate
          },
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(selectedDate.toString().substring(0, 10)),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.white))))),
    ]);
  }

  void showDatePicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (value) {
                if (value != selectedDate) {
                  setState(() {
                    selectedDate = value;
                    print('################################$selectedDate##########################################');
                    int timestamp = selectedDate.millisecondsSinceEpoch;
                    expireDate = timestamp;
                    print('###################################$expireDate@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                    getdatePicker(expireDate);
                   // Navigator.pop(context)
                    //記錄下用戶選擇的時間 ------> 存入數據庫
                  });
                }
              },
              
              initialDateTime: DateTime.now(),
              minimumYear: 2000,
              maximumYear: 2025,
            ),
          
          );
        });
  }
}
