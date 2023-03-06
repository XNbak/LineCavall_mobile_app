import 'package:mobile_app/main.dart';
import 'dart:async';

Future<String> getRows(idnum) async {
  List<Map<String, dynamic>> deviceId =
      await DeviceFieldDatabase.instance.getRowsWhereIdMatches(idnum);
  return deviceId[0].toString();
}

Future<int> getLen(str) async {
  List<Map<String, dynamic>> measfields =
      await MeasFieldDatabase.instance.getRowsWhereNameMatches(str.toString());
  return measfields.length;
}

Future<double> getValHold(row, indent, value) async {
  List<Map<String, dynamic>> measfields =
      await MeasFieldDatabase.instance.getRowsWhereNameMatches(row.toString());
  Map<String, dynamic> serial = measfields[indent];
  double result = serial['value'] as double;
  return result;
}

Future<DateTime> getTimeHold(row, indent) async {
  List<Map<String, dynamic>> measfields =
      await MeasFieldDatabase.instance.getRowsWhereNameMatches(row.toString());
  Map<String, dynamic> serial = measfields[indent];
  String answer = serial['time'];
  DateTime datetimeVal = DateTime.parse(answer);
  return datetimeVal;
}

Future<int> getDevLen() async {
  List<DeviceField> devfields =
      await DeviceFieldDatabase.instance.getDeviceFields();
  var devicelen = devfields.length;
  // ignore: prefer_conditional_assignment, unnecessary_null_comparison
  if (devicelen == null) {
    devicelen = 0;
    return devicelen;
  }
  return devicelen;
}
