import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constants/http_service.dart';
import 'hourly_data.dart';

class PumpLogScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  const PumpLogScreen({super.key, required this.userId, required this.controllerId});

  @override
  State<PumpLogScreen> createState() => _PumpLogScreenState();
}

class _PumpLogScreenState extends State<PumpLogScreen> {
  List<PumpLogModel> pumpLogData = [];
  String message = "";
  List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPumpLog();
  }

  Future<void> getUserPumpLog() async {
    var data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "fromDate": dates.first.toString().split(' ')[0],
      "toDate": dates.last.toString().split(' ')[0],
    };

    try {
      final getPumpController = await HttpService().postRequest("getUserPumpLog", data);
      final response = jsonDecode(getPumpController.body);
      log(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        setState(() {
          if (response['data'] is List) {
            // pumpLogData = response['data'];
            pumpLogData = (response['data'] as List).map((e) => PumpLogModel.parseData(e)).toList();
          } else {
            message = "Data not found";
            log('Data is not a List');
          }
        });
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("$e");
      log("stackTrace ==> $stackTrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pump Log', style: TextStyle(color: Colors.white,),),
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      // backgroundColor: const Color(0xffE9E9E9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 10,),
              ListTile(
                title: Text("${getWeekdayName(selectedDate.weekday)}, ${getMonthName(selectedDate.month)} ${selectedDate.day}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                subtitle: const Text("Today", style: TextStyle(fontWeight: FontWeight.w400),),
                tileColor: Colors.white,
                trailing: IconButton(
                  onPressed: (){
                    showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now()
                    ).then((pickedDateRange) {
                      if (pickedDateRange != null) {
                        setState(() {
                          dates.first = pickedDateRange.start;
                          dates.last = pickedDateRange.end;
                          dates = List.generate(pickedDateRange.end.difference(pickedDateRange.start).inDays, (index) => pickedDateRange.start.add(Duration(days: index)));
                          selectedDate = pickedDateRange.start;
                        });
                      } else {
                        print('Date range picker was canceled');
                      }
                    }).whenComplete(() {
                      getUserPumpLog();
                    });
                  },
                  icon: const Icon(Icons.calendar_month, color: Colors.black,),
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.greenAccent)
                  ),
                ),
              ),
              if(dates.length > 1)
                Container(
                  height: 80,
                  color: Colors.white,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var date in dates)
                        GestureDetector(
                          onTap: () {
                            // print('Selected date: $date');
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 0.85,
                                child: buildDayWidget(
                                    context: context,
                                    date: date.day.toString(),
                                    day: getWeekdayName(date.weekday).substring(0,3).toUpperCase(),
                                    month: getMonthName(date.month).substring(0,3).toUpperCase(),
                                    backgroundColor: date.day == selectedDate.day ? Theme.of(context).primaryColor : date.day == DateTime.now().day ? Colors.greenAccent : Colors.white,
                                    textColor: date.day == selectedDate.day ? Colors.white : date.day == DateTime.now().day ? Colors.black : Theme.of(context).primaryColor
                                ),
                              ),
                              const SizedBox(width: 10,)
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              Container(
                height: 500,
                child: message.isEmpty ? GanttChart(
                  pumpLogModels: pumpLogData,
                ) : Center(child: Text(message),),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PumpLogModel {
  final String date;
  final List<PumpLogData> pumpLogDataList;

  PumpLogModel({required this.date, required this.pumpLogDataList});

  factory PumpLogModel.parseData(Map<String, dynamic> data) {
    print("data in the pump log model ==> $data");
    List<PumpLogData> pumpLogDataList = [];

    // Parse motor1, motor2, and motor3 data
    for (var key in ['motor1', 'motor2', 'motor3']) {
      if (data[key] != null && data[key].toString().isNotEmpty) {
        pumpLogDataList.add(PumpLogData.parseData(data[key].toString()));
      }
    }

    return PumpLogModel(
      date: data['logDate'],
      pumpLogDataList: pumpLogDataList,
    );
  }
}

class PumpLogData {
  final String status;
  final List<String> onTimeList;
  final List<String> offTimeList;

  PumpLogData({required this.onTimeList, required this.offTimeList, required this.status});

  factory PumpLogData.parseData(String data) {
    List<String> onTimeList = [];
    List<String> offTimeList = [];
    for(var i = 0; i < data.split(',').length; i++) {
      if(i != 0 && i != 1) {
        var onTime = "";
        var offTime = "";
        if(data.split(',')[i].contains("N=")) {
          if(data.split(',')[i].split('=')[1].isNotEmpty) {
            onTimeList.add(data.split(',')[i].split('=')[1].trim());
            onTime = data.split(',')[i].split('=')[1].trim();
          }
        } else if(data.split(',')[i].contains("F=")) {
          if(data.split(',')[i].split('=')[1].isNotEmpty) {
            offTimeList.add(data.split(',')[i].split('=')[1].trim());
            offTime = data.split(',')[i].split('=')[1].trim();
          }
        }
      }
    }

    return PumpLogData(
      status: data,
      onTimeList: onTimeList,
      offTimeList: offTimeList,
    );
  }
}

class GanttTask {
  final String label;
  final String startTime;
  final String endTime;

  GanttTask({required this.label, required this.startTime, required this.endTime});
}

class GanttChart extends StatelessWidget {
  final List<PumpLogModel> pumpLogModels;
  final double chartHeight = 30.0;

  const GanttChart({Key? key, required this.pumpLogModels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header: Hours
          buildScale(scale: generateScale(Duration(hours: 24))),
          SizedBox(height: 16),
          // Gantt Chart
          Expanded(
            child: ListView.builder(
              itemCount: pumpLogModels.length,
              itemBuilder: (context, index) {
                final pumpLogModel = pumpLogModels[index];
                try {
                  return Column(
                    children: [
                      for(var i = 0; i < pumpLogModels[index].pumpLogDataList.length; i++)
                        Column(
                          children: [
                            Row(
                              children: [
                                for(var j = 0; j < pumpLogModels[index].pumpLogDataList[i].onTimeList.length; j++)
                                  CustomPaint(
                                    painter: GanttChartPainter(
                                      startPoint: calculateStartPoint(pumpLogModels[index].pumpLogDataList[i].onTimeList[j], context),
                                      endPoint: calculateEndPoint(pumpLogModels[index].pumpLogDataList[i].offTimeList[j], context),
                                    ),
                                    child: Container(
                                      height: chartHeight,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Text("${pumpLogModels[index].pumpLogDataList[i].offTimeList.length}"),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 10,)
                          ],
                        )
                      // Text("${pumpLogModels[index].pumpLogDataList[i].status}")
                    ],
                  );
                } catch(error, stackTrace) {
                  print(stackTrace);
                  return Text("Error: $error");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Offset calculateStartPoint(String startTime, context) {
    print("startTime ==> $startTime");
    final startDateTime = DateFormat('HH:mm:ss').parse(startTime.isNotEmpty ? startTime : "00:00:00");
    final startHour = startDateTime.hour + (startDateTime.minute / 60);
    final startX = (startHour / 24) * 100;
    return Offset(startX * MediaQuery.of(context).size.width / 100, 0);
  }

  Offset calculateEndPoint(String endTime, context) {
    print("endTime ==> $endTime");
    final endDateTime = DateFormat('HH:mm:ss').parse(endTime.isNotEmpty ? endTime : "00:00:00");
    final endHour = endDateTime.hour + (endDateTime.minute / 60);
    final endX = (endHour / 24) * 100;
    return Offset(endX * MediaQuery.of(context).size.width / 100, chartHeight);
  }
}

class GanttChartPainter extends CustomPainter {
  final Offset startPoint; // Start point of the rectangle
  final Offset endPoint; // End point of the rectangle

  GanttChartPainter({required this.startPoint, required this.endPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 0
      ..style = PaintingStyle.fill;

    final rect = Rect.fromPoints(startPoint, endPoint);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}