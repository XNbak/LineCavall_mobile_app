// ignore_for_file: unused_local_variable, avoid_print, use_build_context_synchronously

import 'dart:async';

import 'model/btconnectivity.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// ignore: unused_import
import 'package:path_provider/path_provider.dart';
import 'model/db_helpers.dart';
import 'package:workmanager/workmanager.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';

// MeasField database schema
const String measFieldTable = 'MeasField';
const String colId = 'id';
const String colMeas = 'meas';
const String colValue = 'value';
const String colTime = 'time';
const String colDeviceCopyId = 'deviceId';

// DeviceField database schema
const String deviceFieldTable = 'DeviceField';
const String colDeviceId = 'id';
const String colDeviceName = 'deviceName';

class MeasField {
  int id;
  int meas;
  double value;
  DateTime time;
  int deviceId;

  MeasField({
    required this.id,
    required this.meas,
    required this.value,
    required this.time,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      colId: id,
      colMeas: meas,
      colValue: value,
      colDeviceCopyId: deviceId,
      colTime: time.toIso8601String(),
    };
  }

  factory MeasField.fromMap(Map<String, dynamic> map) {
    return MeasField(
      id: map[colId],
      meas: map[colMeas],
      value: map[colValue],
      deviceId: map[colDeviceCopyId],
      time: DateTime.parse(map[colTime]),
    );
  }
}

class MeasFieldDatabase {
  static final MeasFieldDatabase instance = MeasFieldDatabase._init();

  static Database? _database;

  MeasFieldDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('meas_field.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $measFieldTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colMeas INTEGER,
        $colValue REAL,
        $colDeviceCopyId INTEGER,
        $colTime TEXT
      )
    ''');
    print('database.declared');
  }

  Future<void> insertMeasField(
      int type, int temperature, int deviceId, String time) async {
    final db = await instance.database;

    await db.insert(
      measFieldTable,
      {'meas': type, 'value': temperature, 'deviceId': deviceId, 'time': time},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MeasField>> getMeasFields() async {
    final db = await instance.database;

    const orderBy = '$colTime DESC';
    final result = await db.query(measFieldTable, orderBy: orderBy);

    return result.map((json) => MeasField.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getRowsWhereNameMatches(
      String matchingValue) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> rows = await db.query(
      measFieldTable,
      where: '$colDeviceCopyId = ?',
      whereArgs: [matchingValue],
    );
    return rows;
  }

  Future<void> updateMeasField(MeasField measField) async {
    final db = await instance.database;

    await db.update(
      measFieldTable,
      measField.toMap(),
      where: '$colId = ?',
      whereArgs: [measField.id],
    );
  }

  Future<void> deleteMeasField(int id) async {
    final db = await instance.database;

    await db.delete(
      measFieldTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }
}

class DeviceField {
  int id;
  String deviceName;

  DeviceField({required this.id, required this.deviceName});

  Map<String, dynamic> toMap() {
    return {
      colDeviceId: id,
      colDeviceName: deviceName,
    };
  }

  factory DeviceField.fromMap(Map<String, dynamic> map) {
    return DeviceField(
      id: map[colDeviceId],
      deviceName: map[colDeviceName],
    );
  }
}

class DeviceFieldDatabase {
  static final DeviceFieldDatabase instance = DeviceFieldDatabase._init();

  static Database? _datab;

  DeviceFieldDatabase._init();

  Future<Database> get datab async {
    if (_datab != null) return _datab!;

    _datab = await _initDB('device_field.db');
    return _datab!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $deviceFieldTable (
        $colDeviceId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colDeviceName TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getRowsWhereIdMatches(
      int matchingValue) async {
    final db = await instance.datab;
    final List<Map<String, dynamic>> rows = await db.query(
      deviceFieldTable,
      where: '$colDeviceId = ?',
      whereArgs: [matchingValue],
    );
    return rows;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereNameMatches(
      String matchingValue) async {
    final db = await instance.datab;
    final List<Map<String, dynamic>> rows = await db.query(
      deviceFieldTable,
      where: '$colDeviceName = ?',
      whereArgs: [matchingValue],
    );
    return rows;
  }

  Future<void> insertDeviceField(String deviceField) async {
    final db = await instance.datab;

    await db.insert(
      deviceFieldTable,
      {'deviceName': deviceField},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeviceField>> getDeviceFields() async {
    final db = await instance.datab;

    const orderBy = '$colDeviceId DESC';
    var result = await db.query(deviceFieldTable, orderBy: orderBy);
    return result.map((json) => DeviceField.fromMap(json)).toList();
  }

  Future<void> updateDeviceField(DeviceField deviceField) async {
    final db = await instance.datab;

    await db.update(
      deviceFieldTable,
      deviceField.toMap(),
      where: '$colDeviceId = ?',
      whereArgs: [deviceField.id],
    );
  }

  Future<void> deleteDeviceField(int id) async {
    final db = await instance.datab;

    await db.delete(
      deviceFieldTable,
      where: '$colDeviceId = ?',
      whereArgs: [id],
    );
  }
}

const btBackground = 'btBackground';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case btBackground:
        await connectBLE();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    btBackground,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StartPage());
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LineCavall',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFBC534C), brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const HomePage(
          title: 'Home Page',
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
  });
  // ignore: empty_constructor_bodies
  final String title;
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  RefreshController refreshController = RefreshController(initialRefresh: true);

  void refresher() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
    refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await connectBLE();
        },
        child: const Icon(Icons.refresh, size: 35.0),
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: refreshController,
          onRefresh: refresher,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<int>(
                    future: getDevLen(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        var snapdat = snapshot.data!;
                        return Center(
                          child: Column(
                            children: List.generate(
                              snapdat,
                              (index) {
                                return FutureBuilder<String>(
                                    future: getRows(index),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var textdat = snapshot.data!;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 3.0, bottom: 3.0),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: Colors.red
                                                      .withOpacity(0.7),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16))),
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const InfoDevicePage(),
                                                    settings: RouteSettings(
                                                        arguments: index),
                                                  )),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  height: 65,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      textdat,
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              200,
                                                              255)),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))),
                                        );
                                      } else {
                                        return const Text(
                                            'Error creating list');
                                      }
                                    });
                              },
                            ),
                          ),
                        );
                      } else {
                        return const Text('No Devices Added');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoDevicePage extends StatefulWidget {
  const InfoDevicePage({super.key});
  @override
  InfoDevicePageState createState() => InfoDevicePageState();
}

class InfoDevicePageState extends State<InfoDevicePage> {
  Future<double> sendLastLen(deviceID) async {
    var len = await getLen(deviceID);
    var lastlen = len - 1;
    var lastMeas = await getValHold(deviceID, lastlen, 2);
    return lastMeas;
  }

  Future<List<MeasTableData>> sendMeasTableData(deviceID) async {
    var len = await getLen(deviceID);
    final List<MeasTableData> chartdata = [];
    for (var i = 0; i < len - 1; i++) {
      var val = await getValHold(deviceID, i, 2);
      var time = await getTimeHold(deviceID, i);
      chartdata.add(MeasTableData(time, val));
    }
    return chartdata;
  }

  @override
  Widget build(BuildContext context) {
    var deviceId = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<double>(
                future: sendLastLen(deviceId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var snapdat = snapshot.data!;
                    return Center(
                      child: Column(children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 12.0, left: 12.0, right: 12.0, bottom: 2.0),
                          child: Center(
                            child: Text(
                              'Your animals last recorded temperature was',
                              style: TextStyle(fontSize: 22),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Center(
                            child: Text(
                              '$snapdat',
                              style: const TextStyle(
                                fontSize: 45,
                                color: Color.fromARGB(255, 232, 170, 0),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: FutureBuilder<List<MeasTableData>>(
                                future: sendMeasTableData(deviceId),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<MeasTableData> members =
                                        snapshot.data!;
                                    List<MeasTableData> lasttimes = [];
                                    for (var i in members) {
                                      if (i.time.isAfter(DateTime.now()
                                          .subtract(
                                              const Duration(hours: 24)))) {
                                        lasttimes.add(i);
                                      }
                                    }
                                    if (members.isNotEmpty &&
                                        lasttimes.isNotEmpty) {
                                      return Center(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SfCartesianChart(
                                                  primaryXAxis: DateTimeAxis(),
                                                  series: <ChartSeries>[
                                                    LineSeries<MeasTableData,
                                                            DateTime>(
                                                        dataSource: lasttimes,
                                                        xValueMapper:
                                                            (MeasTableData data,
                                                                    _) =>
                                                                data.time,
                                                        yValueMapper:
                                                            (MeasTableData data,
                                                                    _) =>
                                                                data.val)
                                                  ]),
                                            ),
                                            SfCartesianChart(
                                                primaryXAxis: DateTimeAxis(),
                                                series: <ChartSeries>[
                                                  LineSeries<MeasTableData,
                                                          DateTime>(
                                                      dataSource: members,
                                                      xValueMapper:
                                                          (MeasTableData data,
                                                                  _) =>
                                                              data.time,
                                                      yValueMapper:
                                                          (MeasTableData data,
                                                                  _) =>
                                                              data.val)
                                                ]),
                                          ],
                                        ),
                                      );
                                    } else if (members.isNotEmpty &&
                                        lasttimes.isEmpty) {
                                      return Center(
                                        child: Column(children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                                'No data measureed over the past 24 hours'),
                                          ),
                                          SfCartesianChart(
                                              primaryXAxis: DateTimeAxis(),
                                              series: <ChartSeries>[
                                                LineSeries<MeasTableData,
                                                        DateTime>(
                                                    dataSource: members,
                                                    xValueMapper:
                                                        (MeasTableData data,
                                                                _) =>
                                                            data.time,
                                                    yValueMapper:
                                                        (MeasTableData data,
                                                                _) =>
                                                            data.val)
                                              ]),
                                        ]),
                                      );
                                    } else {
                                      return const Text('No data measured');
                                    }
                                  } else {
                                    return const Text('Loading tables...');
                                  }
                                })),
                          ),
                        )
                      ]),
                    );
                  } else {
                    return const Text('Error returning lastMeas');
                  }
                }),
          ),
        ),
      ),
    );
  }
}

class MeasTableData {
  MeasTableData(this.time, this.val);
  final DateTime time;
  final double val;
}
