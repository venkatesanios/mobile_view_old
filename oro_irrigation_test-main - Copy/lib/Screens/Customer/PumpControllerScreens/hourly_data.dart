import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../constants/http_service.dart';
import '../../../Widgets/SCustomWidgets/custom_segmented_control.dart';
import '../../../Widgets/SCustomWidgets/custom_snack_bar.dart';
import '../IrrigationProgram/preview_screen.dart';

class HourlyData extends StatefulWidget {
  final int userId;
  final int controllerId;
  const HourlyData({super.key, required this.userId, required this.controllerId});

  @override
  State<HourlyData> createState() => _HourlyDataState();
}

class _HourlyDataState extends State<HourlyData> {
  int selectedIndex = 0;
  List hourlyData = [];
  List<MotorDataHourly> motorDataList = [];
  List<PageController> pageController= [];
  List<MotorData> chartData = [];
  List<CommonData> commonDataList = [];
  List<double> currPageValue = [];
  double scaleFactor = 0.8;
  String fromDateStr = "2024-06-01";
  List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getPumpControllerData();
  }

  Future<void> getPumpControllerData({int selectedIndex = 0}) async {
    DateTime fromDate = DateTime.parse(dates.first.toString().split(' ')[0]);
    DateTime toDate;
    String toDateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(dates.last.toString().split(' ')[0]));
    setState(() {
      if (selectedIndex == 1) {
        toDate = fromDate.add(const Duration(days: 7));
      } else if (selectedIndex == 2) {
        toDate = DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      } else {
        toDate = DateTime.parse(dates.last.toString().split(' ')[0]);
      }
      toDateStr = DateFormat('yyyy-MM-dd').format(toDate);
    });

    var data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "fromDate": fromDateStr,
      "toDate": toDateStr,
    };

    print("data ==> $data");
    // print(toDateStr);
    try {
      final getPumpController = await HttpService().postRequest("getUserPumpHourlyLog", data);
      final response = jsonDecode(getPumpController.body);
      // print(response);
      if (getPumpController.statusCode == 200) {
        setState(() {
          if (response['data'] is List) {
            hourlyData = response['data'];
            print(hourlyData);
            print(hourlyData.length);
            handlingChartData(index: 0);
          } else {
            log('Data is not a List');
          }
        });
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("Error ==> $e");
      log("StackTrace ==> $stackTrace");
    }
  }

  void handlingChartData({required int index}) {
    motorDataList = [];
    commonDataList = [];
    chartData = [];
    for (var i = 0; i < hourlyData.length; i++) {
      motorDataList.add(MotorDataHourly.parseData(hourlyData[i]['hourlyData'].toString().split('-')[2].split(',')));
      commonDataList.add(CommonData.parseData(hourlyData[i]['hourlyData'].toString().split('-')[1].split(',')));
    }
    for (var i = 0; i < motorDataList.length; i++) {
      List<Color> colors = [Colors.lightBlueAccent.withOpacity(0.8), Colors.lightGreenAccent, Colors.greenAccent];
      chartData.add(
          MotorData(
              "M${i + 1}",
              ["10:00:00", "08:00:00", "12:00:00"][i],
              colors[i]
          )
      );
    }

    pageController = List.generate(hourlyData.length, (index) => PageController(viewportFraction: 0.95));
    currPageValue = List.generate(hourlyData.length, (index) => 0.0);
    for(var i = 0; i < hourlyData.length; i++) {
      pageController[i].addListener(() {
        setState(() {
          currPageValue[i] = pageController[i].page!;
        });
      });
    }
  }

  // Future<void> generateExcel(logs) async {
  //   var excel = Excel.createExcel();
  //   Sheet sheetObject = excel['Logs'];
  //   List<String> headerRow = [
  //     'S.No',
  //     'Controller Date',
  //     'Controller Time',
  //     'Program Name',
  //     'Zone Name',
  //     'Start Time',
  //     'Duration',
  //     'Valves',
  //     'Cycle No',
  //     'Status',
  //   ];
  //   // Add headers
  //   sheetObject.appendRow(headerRow.toList().map((cell) => TextCellValue(cell)).toList());
  //
  //   // Add log data
  //   // logs.forEach((log) {
  //   //   sheetObject.appendRow(log.values.toList().map((cell) => TextCellValue(cell)).toList());
  //   // });
  //
  //   // Save the file
  //   var fileBytes = excel.encode();
  //   if (fileBytes != null) {
  //     try {
  //       String downloadsDirectoryPath = "/storage/emulated/0/Download";
  //       String filePath = "$downloadsDirectoryPath/logs.xlsx";
  //
  //       File file = File(filePath);
  //       await file.create(recursive: true);
  //       await file.writeAsBytes(fileBytes);
  //
  //       // Check if file exists
  //       if (await file.exists()) {
  //         // print("Excel file saved successfully at $filePath");
  //         showSnackBar(message: "Excel file saved successfully at $filePath");
  //       } else {
  //         log("Failed to save the Excel file.");
  //       }
  //     } catch (e) {
  //       log("Error saving the Excel file: $e");
  //     }
  //   } else {
  //     log("Error encoding the Excel file.");
  //   }
  // }

  Future<void> showSnackBar({required String message}) async{
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message:  message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power and motor",),
        foregroundColor: Theme.of(context).primaryColor,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){
              // generateExcel(hourlyData);
            },
            icon: const Icon(Icons.download),
            // style: ButtonStyle(
            //   backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.05)),
            //   foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
            // ),
          )
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10,),
                CustomSegmentedControl(
                    segmentTitles: const {
                      0: "Days",
                      1: "Weekly",
                      2: "Monthly",
                    },
                    groupValue: selectedIndex,
                    onChanged: (newValue) {
                      setState(() {
                        selectedIndex = newValue!;
                      });
                      getPumpControllerData(selectedIndex: newValue!);
                    }
                ),
                // buildDateRangePicker(context),
                const SizedBox(height: 10,),
                buildDailyDataView(constraints: constraints),
                // if (selectedIndex == 1)
                //   buildWeeklyDataView(),
              ],
            );
          }
      ),
      floatingActionButton: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        textColor: Colors.white,
        color: Theme.of(context).primaryColor,
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
            getPumpControllerData();
          });
        },
        child: Text("From ${DateFormat('MMM d').format(dates.first)} - To ${DateFormat('MMM d').format(dates.last)}"),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget buildDailyDataView({required BoxConstraints constraints}) {
    final selectedCondition = selectedIndex == 0;
    return Expanded(
      child: ListView.builder(
          itemCount: selectedCondition ? hourlyData.length : 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: customBoxShadow
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(selectedCondition)
                        buildHeader(index),
                      const SizedBox(height: 10,),
                      buildScale(scale: generateScale(selectedCondition
                          ? const Duration(hours: 30)
                          : cumulativeDuration(commonDataList.map((e) => e.totalPowerOnTime).toList()))
                      ),
                      const SizedBox(height: 10,),
                      buildAnimatedContainer(
                          color: const Color(0xff15C0E6),
                          value: selectedCondition
                              ? parseTime(commonDataList[index].totalPowerOnTime)
                              : cumulativeDuration(commonDataList.map((e) => e.totalPowerOnTime).toList()),
                          motor: "Total -",
                          highestValue: const Duration(hours: 30)
                      ),
                      const SizedBox(height: 10,),
                      buildMotorStatusContainers(index: index),
                      const SizedBox(height: 10,),
                      buildLegend(),
                      const SizedBox(height: 10,),
                      DoughnutChart(
                        chartData: chartData,
                        totalPowerDuration: selectedCondition
                            ? const Duration(hours: 30)
                            : cumulativeDuration(commonDataList.map((e) => e.totalPowerOnTime).toList()),
                      ),
                      // buildFooter(),
                      if(motorDataList.length == 1)
                        buildMotorDetails(motorIndex: 0, dayIndex: index)
                      else
                        SizedBox(
                            height: 260,
                            child: buildPageView(dayIndex: index, constraints: constraints)
                        ),
                    ],
                  ),
                ),
                SizedBox(height: index == hourlyData.length - 1 ? 80 : 30,)
              ],
            );
          }
      ),
    );
  }

  Widget buildMotorDetails({required int motorIndex, required int dayIndex,}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildItemContainer(
          title1: 'Motor run time',
          title2: "Motor idle time",
          value1: (selectedIndex == 0)
              ? ([motorDataList[dayIndex].motorRunTime1, motorDataList[dayIndex].motorRunTime2, motorDataList[dayIndex].motorRunTime3][motorIndex])
              : ([
            cumulativeDuration(motorDataList.map((e) => e.motorRunTime1).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.motorRunTime2).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.motorRunTime3).toList()).toString().split('.')[0]
          ][motorIndex]),
          value2: (selectedIndex == 0)
              ? ([motorDataList[dayIndex].motorIdleTime1, motorDataList[dayIndex].motorIdleTime2, motorDataList[dayIndex].motorIdleTime3][motorIndex])
              : ([
            cumulativeDuration(motorDataList.map((e) => e.motorIdleTime1).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.motorIdleTime2).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.motorIdleTime3).toList()).toString().split('.')[0]
          ][motorIndex]),
        ),
        buildItemContainer(
          title1: 'Dry run trip time',
          title2: 'Cyclic trip time',
          value1: (selectedIndex == 0)
              ? ([motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3][motorIndex])
              : ([
            cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime1).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime2).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime3).toList()).toString().split('.')[0]
          ][motorIndex]),
          value2: (selectedIndex == 0)
              ? ([motorDataList[dayIndex].cyclicTripTime1, motorDataList[dayIndex].cyclicTripTime2, motorDataList[dayIndex].cyclicTripTime3][motorIndex])
              : ([
            cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime1).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime2).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime3).toList()).toString().split('.')[0]
          ][motorIndex]),
        ),
        buildItemContainer(
          title1: 'Other trip time',
          title2: 'Total flow today',
          value1: (selectedIndex == 0)
              ? ([motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3][motorIndex])
              : ([
            cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime1).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime2).toList()).toString().split('.')[0],
            cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime3).toList()).toString().split('.')[0]
          ][motorIndex]),
          value2: (selectedIndex == 0)
              ? ("${[motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3][motorIndex]} Litres")
              : ("${
              [
                cumulativeFlow(motorDataList.map((e) => e.totalFlowToday1).toList()).toString().split('.')[0],
                cumulativeFlow(motorDataList.map((e) => e.totalFlowToday2).toList()).toString().split('.')[0],
                cumulativeFlow(motorDataList.map((e) => e.totalFlowToday3).toList()).toString().split('.')[0]
              ][motorIndex]
          } Litres"),
        ),
      ],
    );
  }

  Widget buildHeader(int index) {
    return Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5))
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                DateFormat('MMM d yyyy').format(DateTime.parse(hourlyData[index]['date'])),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
          ),
        )
    );
  }

  Widget buildMotorStatusContainers({required int index}) {
    List<Widget> containers = [];
    for (var i = 0; i < 3; i++) {
      containers.add(
          Column(
            children: [
              buildAnimatedContainer(
                  color: const Color(0xff10E196),
                  value: [const Duration(hours: 10), const Duration(hours: 8), const Duration(hours: 12)][i],
                  motor: "M${i + 1}",
                  highestValue: selectedIndex == 0 ? parseTime(commonDataList[index].totalPowerOnTime) : cumulativeDuration(commonDataList.map((e) => e.totalPowerOnTime).toList())
              ),
              const SizedBox(height: 10,)
            ],
          )
      );
    }
    return Column(children: containers);
  }

  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            buildLegendItem(color: const Color(0xff15C0E6), label: "Power Status"),
            const SizedBox(width: 30,),
            buildLegendItem(color: const Color(0xff10E196), label: "Motor Status"),
          ],
        )
      ],
    );
  }

  Widget buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color)),
        const SizedBox(width: 10,),
        Text(label, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14))
      ],
    );
  }

  Widget buildFooter() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildFooterItem("Active power", "Kwh", "10", "Instantaneous power", "10"),
            buildFooterItem("Running hours", "Hrs", "10", "Current power factor", "10")
          ],
        )
    );
  }

  Widget buildFooterItem(String label1, String unit1, String value1, String label2, String value2) {
    return Column(
      children: [
        Text(label1, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
        Text("$value1 $unit1", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10,),
        Text(label2, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
        Text(value2, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget buildItemContainer({
    required String title1,
    required String title2,
    required String value1,
    required String value2
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          buildItemRow(
              title1: title1,
              title2: title2,
              value1: value1,
              value2: value2
          )
        ],
      ),
    );
  }

  Widget buildItemRow({required String title1, required String title2, required String value1, required String value2}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildItem(title: title1, value: value1, color: Theme.of(context).primaryColor),
          buildItem(title: title2, value: value2, color: Colors.red)
        ],
      ),
    );
  }

  Widget buildItem({required String title, required String value, required Color color}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ],
    );
  }

  Duration cumulativeDuration(List<String> durationStrings) {
    int totalMilliseconds = 0;
    for (var durationString in durationStrings) {
      totalMilliseconds += parseTime(durationString).inMilliseconds;
    }
    return Duration(milliseconds: totalMilliseconds);
  }

  String cumulativeFlow(List<String> flowSettings) {
    int flowInLitres = 0;
    for (var flowSetting in flowSettings) {
      flowInLitres += int.parse(flowSetting);
    }
    return flowInLitres.toString();
  }

  String getValue({required int index, required String key, required int splitIndex}) {
    String value = '';
    List<String> keyValuePairs = hourlyData[index]['hourlyData'].toString().split('-')[splitIndex].split(',');
    for (String pair in keyValuePairs) {
      if (pair.startsWith('$key=')) {
        value = pair.split('=')[1];
        break;
      }
    }
    return value;
  }

  Widget buildItemContainer2({
    required String title1,
    required String title2,
    required int index,
    List<String>? value1,
    List<String>? value2,
    required String key1,
    required String key2,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5),
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title1, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.start)),
              for(var i = 0; i < getValue(index: index, key: key1, splitIndex: 2).split(';').length; i++)
                Expanded(flex: 2, child: Text(value1?[i] ?? getValue(index: index, key: key1, splitIndex: 2).split(';')[i], style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title2, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.start)),
              for(var i = 0; i < getValue(index: index, key: key2, splitIndex: 2).split(';').length; i++)
                Expanded(flex: 2, child: Text(value2?[i] ?? getValue(index: index, key: key2, splitIndex: 2).split(';')[i], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPageView({required int dayIndex, required BoxConstraints constraints}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Align(
        //     alignment: Alignment.topRight,
        //     child: Container(
        //       margin: const EdgeInsets.symmetric(horizontal: 10),
        //       height: 22,
        //       child: MaterialButton(
        //           color: Theme.of(context).primaryColor,
        //           onPressed: (){
        //             showModalBottomSheet(
        //                 context: context,
        //                 showDragHandle: true,
        //                 builder: (BuildContext context) {
        //                   return Container(
        //                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        //                     child: Column(
        //                       mainAxisSize: MainAxisSize.min,
        //                       children: [
        //                         Container(
        //                             width: double.maxFinite,
        //                             color: Theme.of(context).primaryColor.withOpacity(0.7),
        //                             child: Padding(
        //                               padding: const EdgeInsets.all(8.0),
        //                               child: Row(
        //                                 mainAxisAlignment: MainAxisAlignment.start,
        //                                 children: [
        //                                   Expanded(flex: 3, child: Container()),
        //                                   for(var i = 0; i < 3; i++)
        //                                     Expanded(flex: 2, child: Text("Motor ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        //                                 ],
        //                               ),
        //                             )
        //                         ),
        //                         buildItemContainer2(
        //                           title1: 'Motor run time',
        //                           title2: "Motor idle time",
        //                           index: dayIndex,
        //                           key1: 'MRUNTIM',
        //                           key2: 'MIDLEPTIM',
        //                           value1: (selectedIndex == 0)
        //                               ? ([motorDataList[dayIndex].motorRunTime1, motorDataList[dayIndex].motorRunTime2, motorDataList[dayIndex].motorRunTime3])
        //                               : ([
        //                             cumulativeDuration(motorDataList.map((e) => e.motorRunTime1).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.motorRunTime2).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.motorRunTime3).toList()).toString().split('.')[0]
        //                           ]),
        //                           value2: (selectedIndex == 0)
        //                               ? ([motorDataList[dayIndex].motorIdleTime1, motorDataList[dayIndex].motorIdleTime2, motorDataList[dayIndex].motorIdleTime3])
        //                               : ([
        //                             cumulativeDuration(motorDataList.map((e) => e.motorIdleTime1).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.motorIdleTime2).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.motorIdleTime3).toList()).toString().split('.')[0]
        //                           ]),
        //                         ),
        //                         buildItemContainer2(
        //                           title1: 'Dry run trip time',
        //                           title2: 'Cyclic trip time',
        //                           index: dayIndex,
        //                           key1: 'DTRIPTIM',
        //                           key2: 'CYCTRIPTIM',
        //                           value1: (selectedIndex == 0)
        //                               ? ([motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3])
        //                               : ([
        //                             cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime1).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime2).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime3).toList()).toString().split('.')[0]
        //                           ]),
        //                           value2: (selectedIndex == 0)
        //                               ? ([motorDataList[dayIndex].cyclicTripTime1, motorDataList[dayIndex].cyclicTripTime2, motorDataList[dayIndex].cyclicTripTime3])
        //                               : ([
        //                             cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime1).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime2).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime3).toList()).toString().split('.')[0]
        //                           ]),
        //                         ),
        //                         buildItemContainer2(
        //                           title1: 'Other trip time',
        //                           title2: 'Total flow today',
        //                           index: dayIndex,
        //                           key1: 'OTRIPTIM',
        //                           key2: 'RFLO',
        //                           value1: (selectedIndex == 0)
        //                               ? ([motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3])
        //                               : ([
        //                             cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime1).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime2).toList()).toString().split('.')[0],
        //                             cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime3).toList()).toString().split('.')[0]
        //                           ]),
        //                           value2: (selectedIndex == 0)
        //                               ? ([motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3])
        //                               : ([
        //                             cumulativeFlow(motorDataList.map((e) => e.totalFlowToday1).toList()).toString().split('.')[0],
        //                             cumulativeFlow(motorDataList.map((e) => e.totalFlowToday2).toList()).toString().split('.')[0],
        //                             cumulativeFlow(motorDataList.map((e) => e.totalFlowToday3).toList()).toString().split('.')[0]
        //                           ]),
        //                         ),
        //                       ],
        //                     ),
        //                   );
        //                 }
        //             );
        //           },
        //           elevation: 10,
        //           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(20)
        //           ),
        //           child: const Text("View All", style: TextStyle(color: Colors.white, fontSize: 11),)
        //       ),
        //     )
        // ),
        // if(constraints.maxWidth <= 600)
        //   Expanded(
        //     child: PageView.builder(
        //       controller: pageController[dayIndex],
        //       scrollDirection: Axis.horizontal,
        //       itemCount: motorDataList.length,
        //       allowImplicitScrolling: true,
        //       pageSnapping: true,
        //       itemBuilder: (BuildContext context, int motorIndex) {
        //         return buildPageItem(
        //             context: context,
        //             index: motorIndex,
        //             pageControllerIndex: dayIndex,
        //             subChild: Text("Motor ${motorIndex+1}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
        //             child: buildMotorDetails(motorIndex: motorIndex, dayIndex: dayIndex),
        //             currPageValue: currPageValue,
        //             height: 260,
        //             scaleFactor: 0.8
        //         );
        //       },
        //     ),
        //   )
        // else
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: double.maxFinite,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: Container()),
                        for(var i = 0; i < 3; i++)
                          Expanded(flex: 2, child: Text("Motor ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                  )
              ),
              buildItemContainer2(
                title1: 'Motor run time',
                title2: "Motor idle time",
                index: dayIndex,
                key1: 'MRUNTIM',
                key2: 'MIDLEPTIM',
                value1: (selectedIndex == 0)
                    ? ([motorDataList[dayIndex].motorRunTime1, motorDataList[dayIndex].motorRunTime2, motorDataList[dayIndex].motorRunTime3])
                    : ([
                  cumulativeDuration(motorDataList.map((e) => e.motorRunTime1).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.motorRunTime2).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.motorRunTime3).toList()).toString().split('.')[0]
                ]),
                value2: (selectedIndex == 0)
                    ? ([motorDataList[dayIndex].motorIdleTime1, motorDataList[dayIndex].motorIdleTime2, motorDataList[dayIndex].motorIdleTime3])
                    : ([
                  cumulativeDuration(motorDataList.map((e) => e.motorIdleTime1).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.motorIdleTime2).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.motorIdleTime3).toList()).toString().split('.')[0]
                ]),
              ),
              buildItemContainer2(
                title1: 'Dry run trip time',
                title2: 'Cyclic trip time',
                index: dayIndex,
                key1: 'DTRIPTIM',
                key2: 'CYCTRIPTIM',
                value1: (selectedIndex == 0)
                    ? ([motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3])
                    : ([
                  cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime1).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime2).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime3).toList()).toString().split('.')[0]
                ]),
                value2: (selectedIndex == 0)
                    ? ([motorDataList[dayIndex].cyclicTripTime1, motorDataList[dayIndex].cyclicTripTime2, motorDataList[dayIndex].cyclicTripTime3])
                    : ([
                  cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime1).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime2).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.cyclicTripTime3).toList()).toString().split('.')[0]
                ]),
              ),
              buildItemContainer2(
                title1: 'Other trip time',
                title2: 'Total flow today',
                index: dayIndex,
                key1: 'OTRIPTIM',
                key2: 'RFLO',
                value1: (selectedIndex == 0)
                    ? ([motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3])
                    : ([
                  cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime1).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime2).toList()).toString().split('.')[0],
                  cumulativeDuration(motorDataList.map((e) => e.dryRunTripTime3).toList()).toString().split('.')[0]
                ]),
                value2: (selectedIndex == 0)
                    ? ([motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3])
                    : ([
                  cumulativeFlow(motorDataList.map((e) => e.totalFlowToday1).toList()).toString().split('.')[0],
                  cumulativeFlow(motorDataList.map((e) => e.totalFlowToday2).toList()).toString().split('.')[0],
                  cumulativeFlow(motorDataList.map((e) => e.totalFlowToday3).toList()).toString().split('.')[0]
                ]),
              ),
            ],
          ),
        )
      ],
    );
  }
}

Duration parseTime(String timeString) {
  // print(timeString);
  List<String> parts = timeString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitHours = twoDigits(duration.inHours.remainder(24));
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
}

Widget buildPageItem({
  required BuildContext context,
  required int index,
  required Widget subChild,
  required Widget child,
  required int pageControllerIndex,
  required currPageValue,
  required height,
  required scaleFactor
}) {
  double currentPage = currPageValue[pageControllerIndex];
  // print("_currPageValue"+currPageValue.toString());
  // print("index"+index.toString());
  double currScale;
  double currTrans;
  if (index == currentPage.floor()) {
    currScale = 1 - (currentPage - index) * (1 - scaleFactor);
    currTrans = height * (1 - currScale) / 2;
  } else if (index == currentPage.floor() + 1) {
    currScale = scaleFactor + (currentPage - index + 1) * (1 - scaleFactor);
    currTrans = height * (1 - currScale) / 2;
  } else if (index == currentPage.floor() - 1) {
    currScale = 1 - (currentPage - index) * (1 - scaleFactor);
    currTrans = height * (1 - currScale) / 2;
  } else {
    currScale = 0.8;
    currTrans = height * (1 - currScale) / 2;
  }

  Matrix4 matrix = Matrix4.identity()
    ..setEntry(0, 0, 1)
    ..setEntry(1, 1, currScale)
    ..setEntry(2, 2, 1)
    ..setTranslationRaw(0, currTrans, 0);

  return Transform(
    transform: matrix,
    child: Stack(
      children: [
        Container(
          // height: 200,
          // width: double.maxFinite,
          margin: const EdgeInsets.only(bottom: 20, top: 20, right: 5, left: 5),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(15),
          //     boxShadow: neumorphicButtonShadow,
          //     color: Colors.white
          // ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
            color: index.isEven
                ? const Color.fromARGB(255, 114, 218, 232)
                : const Color.fromARGB(255, 94, 101, 239),
          ),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  child: child
              )
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: subChild,
          ),
        ),
      ],
    ),
  );
}

Widget buildDayWidget({
  required BuildContext context,
  required String date,
  required String day,
  required String month,
  Color backgroundColor = Colors.white,
  Color textColor = Colors.black,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20)
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day, style: TextStyle(color: textColor, fontWeight: FontWeight.normal, fontSize: 10),),
        Text(date, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(month, style: TextStyle(color: textColor, fontWeight: FontWeight.normal, fontSize: 10)),
      ],
    ),
  );
}

String getWeekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return '';
  }
}

String getMonthName(int month) {
  switch (month) {
    case DateTime.january:
      return 'January';
    case DateTime.february:
      return 'February';
    case DateTime.march:
      return 'March';
    case DateTime.april:
      return 'April';
    case DateTime.may:
      return 'May';
    case DateTime.june:
      return 'June';
    case DateTime.july:
      return 'July';
    case DateTime.august:
      return 'August';
    case DateTime.september:
      return 'September';
    case DateTime.october:
      return 'October';
    case DateTime.november:
      return 'November';
    case DateTime.december:
      return 'December';
    default:
      return '';
  }
}

class PieChartExample extends StatelessWidget {
  const PieChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    List<MotorData> chartData = [
      MotorData('Motor 1', '01:00:00', Colors.green),
      MotorData('Motor 2', '00:30:00', Colors.lightGreen),
      MotorData('Motor 3', '00:45:00', Colors.lime),
    ];

    Duration totalPowerDuration = const Duration(hours: 3);

    List<PieChartData> pieChartData = chartData.map((motor) {
      Duration motorDuration = parseTime(motor.powerConsumed);
      double percentage = motorDuration.inMilliseconds /
          totalPowerDuration.inMilliseconds *
          100;
      return PieChartData(motor.name, percentage, motor.powerConsumed, motor.color);
    }).toList();

    Duration totalMotorDuration = const Duration();
    for (var motor in chartData) {
      totalMotorDuration += parseTime(motor.powerConsumed);
    }
    Duration balancePowerDuration = totalPowerDuration - totalMotorDuration;
    double balancePercentage = balancePowerDuration.inMilliseconds /
        totalPowerDuration.inMilliseconds *
        100;
    pieChartData.add(PieChartData('Remaining', balancePercentage, formatTime(balancePowerDuration), Colors.greenAccent));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Total Power Availability: ${totalPowerDuration.toString()}'),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<PieChartData, String>(
                  dataSource: pieChartData,
                  xValueMapper: (PieChartData data, _) => data.name,
                  yValueMapper: (PieChartData data, _) => data.percentage,
                  dataLabelMapper: (PieChartData data, _) => '${data.name}: ${data.duration}',
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  pointColorMapper: (PieChartData data, _) => data.color,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MotorData {
  final String name;
  final String powerConsumed;
  final Color color;

  MotorData(this.name, this.powerConsumed, this.color);
}

class PieChartData {
  final String name;
  final double percentage;
  final String duration;
  final Color color;

  PieChartData(this.name, this.percentage, this.duration, this.color);
}

class DoughnutChart extends StatelessWidget {
  final List<MotorData> chartData;
  final Duration totalPowerDuration;
  const DoughnutChart({super.key, required this.chartData, required this.totalPowerDuration});

  @override
  Widget build(BuildContext context) {

    List<PieChartData> pieChartData = chartData.map((motor) {
      Duration motorDuration = parseTime(motor.powerConsumed);
      double percentage = (motorDuration.inMilliseconds / totalPowerDuration.inMilliseconds) * 100;
      return PieChartData(motor.name, percentage, motor.powerConsumed, motor.color);
    }).toList();

    Duration totalMotorDuration = const Duration();
    for (var motor in chartData) {
      totalMotorDuration += parseTime(motor.powerConsumed);
      // print(totalMotorDuration);
    }
    Duration balancePowerDuration = totalPowerDuration - totalMotorDuration;
    double balancePercentage = (balancePowerDuration.inMilliseconds / totalPowerDuration.inMilliseconds) * 100;
    pieChartData.add(PieChartData('Rem', balancePercentage, balancePowerDuration.toString().split('.')[0], const Color(0xff15C0E6)));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Total duration: ${totalPowerDuration.toString().split('.')[0]}"),
          SizedBox(
            height: 180,
            child: SfCircularChart(
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Text(
                    '${pieChartData[0].percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              series: <CircularSeries>[
                DoughnutSeries<PieChartData, String>(
                  dataSource: pieChartData,
                  xValueMapper: (PieChartData data, _) => data.name,
                  yValueMapper: (PieChartData data, _) => data.percentage,
                  dataLabelMapper: (PieChartData data, _) => '${data.name}: ${data.duration}',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    labelPosition: ChartDataLabelPosition.outside,
                    labelAlignment: ChartDataLabelAlignment.auto,
                  ),
                  pointColorMapper: (PieChartData data, _) => data.color,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MotorDataHourly {
  final String motorRunTime1;
  final String motorIdleTime1;
  final String lastDateRunTime1;
  final String lastDateRunFlow1;
  final String dryRunTripTime1;
  final String cyclicTripTime1;
  final String otherTripTime1;
  final String totalFlowToday1;
  final String motorRunTime2;
  final String motorIdleTime2;
  final String lastDateRunTime2;
  final String lastDateRunFlow2;
  final String dryRunTripTime2;
  final String cyclicTripTime2;
  final String otherTripTime2;
  final String totalFlowToday2;
  final String motorRunTime3;
  final String motorIdleTime3;
  final String lastDateRunTime3;
  final String lastDateRunFlow3;
  final String dryRunTripTime3;
  final String cyclicTripTime3;
  final String otherTripTime3;
  final String totalFlowToday3;

  MotorDataHourly({
    required this.motorRunTime1,
    required this.motorIdleTime1,
    required this.lastDateRunTime1,
    required this.lastDateRunFlow1,
    required this.dryRunTripTime1,
    required this.cyclicTripTime1,
    required this.otherTripTime1,
    required this.totalFlowToday1,
    required this.motorRunTime2,
    required this.motorIdleTime2,
    required this.lastDateRunTime2,
    required this.lastDateRunFlow2,
    required this.dryRunTripTime2,
    required this.cyclicTripTime2,
    required this.otherTripTime2,
    required this.totalFlowToday2,
    required this.motorRunTime3,
    required this.motorIdleTime3,
    required this.lastDateRunTime3,
    required this.lastDateRunFlow3,
    required this.dryRunTripTime3,
    required this.cyclicTripTime3,
    required this.otherTripTime3,
    required this.totalFlowToday3,
  });

  factory MotorDataHourly.parseData(List data){
    // print(data);
    List dataList = [];
    for(var i = 0; i < data.length; i++) {
      // print(data);
      if(data[i].toString().isNotEmpty) {
        // print(data[i]);
        dataList.add(data[i].toString().split('=')[1]);
      }
      // print(dataList);
    }

    return MotorDataHourly(
      motorRunTime1: dataList[4].toString().split(';')[0],
      motorIdleTime1: dataList[5].toString().split(';')[0],
      lastDateRunTime1: dataList[2].toString().split(';')[0],
      lastDateRunFlow1: dataList[3].toString().split(';')[0],
      dryRunTripTime1: dataList[6].toString().split(';')[0],
      cyclicTripTime1: dataList[7].toString().split(';')[0],
      otherTripTime1: dataList[8].toString().split(';')[0],
      totalFlowToday1: dataList[1].toString().split(';')[0],
      motorRunTime2: dataList[4].toString().split(';')[1],
      motorIdleTime2: dataList[5].toString().split(';')[1],
      lastDateRunTime2: dataList[2].toString().split(';')[1],
      lastDateRunFlow2: dataList[3].toString().split(';')[1],
      dryRunTripTime2: dataList[6].toString().split(';')[1],
      cyclicTripTime2: dataList[7].toString().split(';')[1],
      otherTripTime2: dataList[8].toString().split(';')[1],
      totalFlowToday2: dataList[1].toString().split(';')[1],
      motorRunTime3: dataList[4].toString().split(';')[2],
      motorIdleTime3: dataList[5].toString().split(';')[2],
      lastDateRunTime3: dataList[2].toString().split(';')[2],
      lastDateRunFlow3: dataList[3].toString().split(';')[2],
      dryRunTripTime3: dataList[6].toString().split(';')[2],
      cyclicTripTime3: dataList[7].toString().split(';')[2],
      otherTripTime3: dataList[8].toString().split(';')[2],
      totalFlowToday3: dataList[1].toString().split(';')[2],
    );
  }
}

class CommonData {
  final String twoPhasePowerOnTime;
  final String twoPhaseLastPowerOnTime;
  final String threePhasePowerOnTime;
  final String threePhaseLastPowerOnTime;
  final String powerOffTime;
  final String lastPowerOnTime;
  final String totalPowerOnTime;
  final String totalPowerOffTime;

  CommonData({
    required this.twoPhasePowerOnTime,
    required this.twoPhaseLastPowerOnTime,
    required this.threePhasePowerOnTime,
    required this.threePhaseLastPowerOnTime,
    required this.powerOffTime,
    required this.lastPowerOnTime,
    required this.totalPowerOnTime,
    required this.totalPowerOffTime,
  });

  factory CommonData.parseData(List data) {
    List dataList = [];
    for(var i = 0; i < data.length; i++) {
      dataList.add(data[i].toString().split('=')[1]);
    }
    // print(dataList);
    return CommonData(
        twoPhasePowerOnTime: dataList[0],
        twoPhaseLastPowerOnTime: dataList[1],
        threePhasePowerOnTime: dataList[2],
        threePhaseLastPowerOnTime: dataList[3],
        powerOffTime: dataList[4],
        lastPowerOnTime: dataList[5],
        totalPowerOnTime: dataList[6],
        totalPowerOffTime: dataList[7]
    );
  }
}

List<String> generateScale(Duration highestValue) {
  final int highestValueInMinutes = highestValue.inMinutes;
  const int segmentCount = 3;
  final List<String> scale = [];
  for (var i = 0; i <= segmentCount; i++) {
    final valueInMinutes = (highestValueInMinutes / segmentCount * i).toInt();
    final value = Duration(minutes: valueInMinutes);
    scale.add("${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}");
  }
  return scale;
}

Widget buildScale({required List<String> scale}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: scale.map((value) => Text(value, style: const TextStyle(color: Color(0xff9291A5)))).toList(),
  );
}

Widget buildAnimatedContainer({required Color color, required Duration value, required String motor, required Duration highestValue}) {
  final percentage = value.inMilliseconds / highestValue.inMilliseconds;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    height: 30,
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xffF5F7F9),
              borderRadius: BorderRadius.circular(2)
          ),
        ),
        AnimatedFractionallySizedBox(
          widthFactor: percentage > 1 ? 1 : percentage,
          duration: const Duration(milliseconds: 1300),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Center(
            child: motor.isNotEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    motor,
                    style: TextStyle(
                        color: percentage >= 0.5 ? Colors.white : Colors.black
                    )
                ),
                const SizedBox(width: 5,),
                Text(
                    "${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(
                        color: percentage >= 0.5 ? Colors.white : Colors.black
                    )
                ),
              ],
            )
                : Text(
                "${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}",
                style: TextStyle(
                    color: percentage >= 0.5 ? Colors.white : Colors.black
                )
            )
        )
      ],
    ),
  );
}