import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/Screens/Customer/IrrigationProgram/preview_screen.dart';
import 'package:oro_irrigation_new/Screens/Customer/IrrigationProgram/schedule_screen.dart';
import 'package:oro_irrigation_new/state_management/irrigation_program_main_provider.dart';
import 'package:provider/provider.dart';

import '../../../Models/IrrigationModel/sequence_model.dart';
import '../../../constants/MQTTManager.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import '../ScheduleView.dart';
import 'irrigation_program_main.dart';

class ProgramLibraryScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final String deviceId;
  final String siteName;
  final int customerID;
  const ProgramLibraryScreen({super.key, required this.userId, required this.controllerId, required this.deviceId, required this.siteName, required this.customerID});

  @override
  State<ProgramLibraryScreen> createState() => _ProgramLibraryScreenState();
}

class _ProgramLibraryScreenState extends State<ProgramLibraryScreen> {
  late MqttPayloadProvider mqttPayloadProvider;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _programNameFocusNode = FocusNode();
  late IrrigationProgramProvider irrigationProgramMainProvider;
  int currentIndex = 0;
  TextEditingController copyController = TextEditingController();
  String tempProgramName = '';
  String controllerReadStatus = "0";

  @override
  void initState() {
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        irrigationProgramMainProvider = Provider.of<IrrigationProgramProvider>(context, listen: false);
        mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
        irrigationProgramMainProvider.programLibraryData(widget.userId, widget.controllerId);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _programNameFocusNode.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    irrigationProgramMainProvider = Provider.of<IrrigationProgramProvider>(context, listen: true);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    // print(irrigationProgramMainProvider.programLibrary!.program.where((element) => element.programName != "").length);

    return Scaffold(
      backgroundColor: const Color(0xffF9FEFF),
      appBar: MediaQuery.of(context).size.width < 550 ?
      AppBar(
        surfaceTintColor: Colors.white,
        title: const Text('Program Library'),
        centerTitle: false,
        actions: [
          // IconButton(
          //   onPressed: () {
          //     if (irrigationProgramMainProvider.programLibrary?.agitatorCount != 0) {
          //       createProgram(context);
          //     } else {
          //       // navigateProgramOnCondition(mainProvider);
          //     }
          //   },
          //   icon: const Icon(Icons.add),
          // ),
          IconButton(
              onPressed: (){
                irrigationProgramMainProvider.programLibraryData(widget.userId, widget.controllerId);
              },
              icon: const Icon(Icons.refresh)
          )
        ],
      ) : PreferredSize(preferredSize: const Size(0, 0), child: Container()),
      body: irrigationProgramMainProvider.programLibrary != null ?
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double cardSize = 0.0;
          if(constraints.maxWidth < 800){
            cardSize = constraints.maxWidth -20;
          }else{
            cardSize = 400;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(irrigationProgramMainProvider.programLibrary!.program.any((element) => element.programName.isEmpty) && constraints.maxWidth < 800)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  // padding: const EdgeInsets.symmetric(vertical: 10),
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(50),
                  //     color: Theme.of(context).primaryColor.withOpacity(0.1)
                  // ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for(var i = 0; i < irrigationProgramMainProvider.filterList.length; i++)
                          buildSideBarMenuList(
                            context: context,
                            title: irrigationProgramMainProvider.filterList[i],
                            dataList: irrigationProgramMainProvider.filterList,
                            index: i,
                            selected: irrigationProgramMainProvider.selectedFilterType == i,
                            onTap: (index) {
                              irrigationProgramMainProvider.updateSelectedFilterType(index);
                              // scheduleViewProvider.updateSelectedProgramCategory(index);
                            }, constraints: constraints,
                          ),
                      ],
                    ),
                  ),
                ),
              if(irrigationProgramMainProvider.programLibrary!.program.any((element) => element.programName.isEmpty) && constraints.maxWidth >= 800)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for(var i = 0; i < irrigationProgramMainProvider.filterList.length; i++)
                        MaterialButton(
                          onPressed: (){
                            irrigationProgramMainProvider.updateSelectedFilterType(i);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: irrigationProgramMainProvider.selectedFilterType == i ? Theme.of(context).primaryColor : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Text(irrigationProgramMainProvider.filterList[i], style: TextStyle(color: irrigationProgramMainProvider.selectedFilterType == i ? Colors.white : Theme.of(context).primaryColor),),
                          ),
                        )
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    // spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    children: [
                      for(var index = 0; index < irrigationProgramMainProvider.programLibrary!.program.length; index++)
                        if(irrigationProgramMainProvider.selectedFilterType == 0 && irrigationProgramMainProvider.programLibrary!.program[index].programName.isNotEmpty)
                          buildProgramItem(
                              programItem: irrigationProgramMainProvider.programLibrary!.program[index],
                              programLibraryData: irrigationProgramMainProvider.programLibrary!.program,
                              cardSize: cardSize,
                              index: index,
                              constraints: constraints
                          )
                      else if(irrigationProgramMainProvider.selectedFilterType == 1 && irrigationProgramMainProvider.programLibrary!.program[index].programName.isEmpty)
                          buildProgramItem(
                              programItem: irrigationProgramMainProvider.programLibrary!.program[index],
                              programLibraryData: irrigationProgramMainProvider.programLibrary!.program,
                              cardSize: cardSize,
                              index: index,
                              constraints: constraints
                          )
                    ],
                  ),
                  // child: customizeGridView(
                  //     maxWith: cardSize + 20,
                  //     maxHeight: 280,
                  //     screenWidth: constraints.maxWidth,
                  //     listOfWidget: [
                  //       for(var index = 0; index < irrigationProgramMainProvider.programLibrary!.program.length; index++)
                  //         SizedBox(
                  //           width: cardSize,
                  //           child: Column(
                  //             children: [
                  //               buildProgramItem(
                  //                   programItem: irrigationProgramMainProvider.programLibrary!.program[index],
                  //                   programLibraryData: irrigationProgramMainProvider.programLibrary!.program,
                  //                   cardSize: cardSize,
                  //                   index: index,
                  //                   constraints: constraints
                  //               ),
                  //               const SizedBox(height: 20,),
                  //             ],
                  //           ),
                  //         ),
                  //     ]
                  // )
                ),
              ),
              // Expanded(
              //   child: SingleChildScrollView(
              //     child: customizeGridView(
              //         maxWith: cardSize + 20,
              //         maxHeight: 280,
              //         screenWidth: constraints.maxWidth,
              //         listOfWidget: [
              //           for(var index = 0; index < irrigationProgramMainProvider.programLibrary!.program.length; index++)
              //             SizedBox(
              //               width: cardSize,
              //               child: Column(
              //                 children: [
              //                   buildProgramItem(
              //                       programItem: irrigationProgramMainProvider.programLibrary!.program[index],
              //                       programLibraryData: irrigationProgramMainProvider.programLibrary!.program,
              //                       cardSize: cardSize,
              //                       index: index,
              //                       constraints: constraints
              //                   ),
              //                   const SizedBox(height: 20,),
              //                 ],
              //               ),
              //             ),
              //         ]
              //     ),
              //   ),
              // ),
            ],
          );
        },
      )
          : const Center(child: CircularProgressIndicator(),),
      floatingActionButton: MaterialButton(
        onPressed: () => createProgram(context),
        color: Theme.of(context).primaryColor,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: const Text("+  Create", style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget buildProgramItem({
    required Program programItem,
    required programLibraryData,
    required cardSize,
    required int index,
    required BoxConstraints constraints,}) {
    final scheduleByDays = programItem.schedule['selected'] == irrigationProgramMainProvider.scheduleTypes[1];
    final scheduleAsRunList = programItem.schedule['selected'] == irrigationProgramMainProvider.scheduleTypes[2];
    final ScrollController itemScrollController = ScrollController();
    final PageController pageController = PageController();

    final startDate = scheduleByDays
        ? programItem.schedule['scheduleAsRunList']['schedule']['startDate']
        : scheduleAsRunList
        ? programItem.schedule['scheduleByDays']['schedule']['startDate']
        : DateTime.now().toString();
    final endDate = scheduleByDays
        ? programItem.schedule['scheduleAsRunList']['schedule']['endDate']
        : scheduleAsRunList
        ? programItem.schedule['scheduleByDays']['schedule']['endDate']
        : DateTime.now().toString();

    final isForceToEndDate = scheduleByDays
        ? programItem.schedule['scheduleAsRunList']['schedule']['isForceToEndDate']
        : scheduleAsRunList
        ? programItem.schedule['scheduleByDays']['schedule']['isForceToEndDate']
        : false;

    final rtcType = scheduleByDays
        ? programItem.schedule['scheduleAsRunList']['rtc']
        : scheduleAsRunList
        ? programItem.schedule['scheduleByDays']['rtc']
        : "";
    int pageCount = rtcType.isNotEmpty ? rtcType.length : 0;

    final startDateOnly = DateFormat('MMM d').format(DateTime.parse(startDate));
    final endDateOnly = DateFormat('MMM d').format(DateTime.parse(endDate));
    String getWeekday(int weekday) {
      const daysInWeek = 7;
      List<String> weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      int adjustedWeekday = (weekday - 1 + daysInWeek) % daysInWeek;

      return weekdays[adjustedWeekday];
    }
    List<String> days = List.generate(
      scheduleByDays
          ? int.parse(programItem.schedule['scheduleAsRunList']['schedule']['noOfDays'].toString().isNotEmpty ? programItem.schedule['scheduleAsRunList']['schedule']['noOfDays'].toString() : "1")
          : scheduleAsRunList
          ? int.parse(programItem.schedule['scheduleByDays']['schedule']['runDays'].toString()) + int.parse(programItem.schedule['scheduleByDays']['schedule']['skipDays'].toString())
          : 0,
          (index) {
        DateTime currentDate = DateTime.parse(startDate).add(Duration(days: index));
        return getWeekday(currentDate.weekday);
      },
    );

    return InkWell(
      onTap: () => programItem.programName.isNotEmpty ? navigateToIrrigationProgram(programItem) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
        width: 360,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: customBoxShadow,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text((scheduleByDays || scheduleAsRunList) ? "$startDateOnly - ${(isForceToEndDate ?? false) ? endDateOnly : "No end date"}" : "Manual start", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
                if(programItem.programName.isNotEmpty)
                  Row(
                    children: [
                      buildIconActionWidget(
                          icon: Icons.copy,
                          iconColor: Theme.of(context).primaryColor,
                          containerColor: const Color(0xffE0FFF7),
                          toolTip: "Copy",
                          onTap: () {
                            tempProgramName = "";
                            copyController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: copyController.text.length,
                            );
                            // Define a default Program object
                            final serialNumber = irrigationProgramMainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                                ? irrigationProgramMainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber
                                : irrigationProgramMainProvider.programLibrary!.program.length+1;
                            final programType = programItem.programType;
                            final elseCondition = Program(programId: 0, serialNumber: serialNumber, programName: programItem.programName, defaultProgramName: programItem.defaultProgramName, programType: programType, priority: "", sequence: [], schedule: {}, hardwareData: {}, controllerReadStatus: '');
                            String programName = irrigationProgramMainProvider.programLibrary!.program.firstWhere((element) => element.serialNumber == serialNumber, orElse: () => elseCondition).programName;
                            String defaultProgramName = irrigationProgramMainProvider.programLibrary!.program.firstWhere((element) => element.serialNumber == serialNumber, orElse: () => elseCondition).defaultProgramName;
                            // copyController.text = irrigationProgramMainProvider.programLibrary!.program.firstWhere((element) => element.serialNumber == serialNumber, orElse: () => elseCondition).programName.isNotEmpty
                            //     ? programName
                            //     : defaultProgramName;
                            copyController.text = programName.isNotEmpty
                                ? programName
                                : defaultProgramName;
                            programCopy(program: programItem, serialNumber: serialNumber, programType: programType, programName: programName, defaultProgramName: defaultProgramName);
                          }
                      ),
                      const SizedBox(width: 10,),
                      buildIconActionWidget(
                          icon: Icons.delete,
                          iconColor: const Color(0xfffd847c),
                          containerColor: const Color(0xffFFDEDC),
                          toolTip: "Reset program",
                          onTap: () => showDeleteConfirmationDialog(programItem)
                      ),
                      const SizedBox(width: 10,),
                      buildIconActionWidget(
                          icon: Icons.edit,
                          iconColor: const Color(0xffFFB27D),
                          containerColor: const Color(0xffFFF0E5),
                          toolTip: "Edit",
                          onTap: () => showEditItemDialog(programItem, index)
                      ),
                      const SizedBox(width: 10,),
                      buildIconActionWidget(
                        icon: Icons.send,
                        iconColor: programItem.controllerReadStatus == "1" ? const Color(
                            0xff10b637) : const Color(0xfffbcd38),
                        containerColor: programItem.controllerReadStatus == "1" ? const Color(
                            0xffd2f3df) : const Color(0xfffbefc6),
                        toolTip: "Send",
                        onTap: () async{
                          Map<String, dynamic> dataToMqtt = programItem.hardwareData;

                          try {
                            await validatePayloadSent(
                                dialogContext: context,
                                context: context,
                                mqttPayloadProvider: mqttPayloadProvider,
                                acknowledgedFunction: () {
                                  setState(() {
                                    controllerReadStatus = "1";
                                  });
                                  // showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']} from controller",);
                                },
                                payload: dataToMqtt,
                                payloadCode: "2500",
                                deviceId: widget.deviceId
                            ).whenComplete(() async {
                              if(mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['Code'] != "200") {
                                setState(() {
                                  controllerReadStatus = "0";
                                });
                              }
                            });
                            await saveProgramDetails(programItem);
                            await Future.delayed(const Duration(seconds: 2), () async{
                              await irrigationProgramMainProvider.programLibraryData(widget.userId, widget.controllerId,);
                            });
                          } catch (error) {
                            showSnackBar(message: 'Failed to update because of $error',);
                            print("Error: $error");
                          }
                        },
                      ),
                      // const SizedBox(width: 10,),
                      // buildIconActionWidget(
                      //     icon: Icons.remove_red_eye,
                      //     iconColor: Theme.of(context).primaryColor,
                      //     containerColor: const Color(0xffE0FFF7),
                      //     toolTip: "View program",
                      //     onTap: () => navigateToIrrigationProgram(programItem)
                      // ),
                      // CircleAvatar(radius: 6,backgroundColor: programItem.controllerReadStatus == "1" ? Colors.green : Colors.red,)
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => navigateToIrrigationProgram(programItem),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(programItem.programName.isNotEmpty ? programItem.programName : programItem.defaultProgramName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),),
                      Text(programItem.programType, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Text(programItem.sequence.length > 1 ? "${programItem.sequence.length} Zones" : "${programItem.sequence.length} Zone", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programItem.programName.isNotEmpty
                          ? programItem.schedule['selected'].toString().toLowerCase().substring(0,1).toUpperCase() + programItem.schedule['selected'].toString().toLowerCase().substring(1)
                          : "Inactive program", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: programItem.programName.isNotEmpty ? Colors.black : Colors.grey),),
                    Container(
                      height: 30,
                      width: cardSize - 180,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          itemScrollController.jumpTo(itemScrollController.offset - details.primaryDelta! / 2);
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.antiAlias,
                          controller: itemScrollController,
                          child: Row(
                            children: [
                              if(programItem.schedule['selected'] == irrigationProgramMainProvider.scheduleTypes[1])
                                for(var index = 0; index < int.parse(programItem.schedule['scheduleAsRunList']['schedule']['noOfDays'].toString().isNotEmpty ? programItem.schedule['scheduleAsRunList']['schedule']['noOfDays'].toString() : "1"); index++)
                                  buildScheduleMethodOfDay(
                                    // method: programItem.schedule['scheduleAsRunList']['schedule']['type'][index] == irrigationProgramMainProvider.scheduleOptions[0]
                                    //     ? "N"
                                    //     : programItem.schedule['scheduleAsRunList']['schedule']['type'][index] == irrigationProgramMainProvider.scheduleOptions[1]
                                    //     ? "O"
                                    //     : programItem.schedule['scheduleAsRunList']['schedule']['type'][index] == irrigationProgramMainProvider.scheduleOptions[2]
                                    //     ? "W"
                                    //     : "F",
                                      method: days[index],
                                      color: programItem.schedule['scheduleAsRunList']['schedule']['type'][index] == irrigationProgramMainProvider.scheduleOptions[0]
                                          ? const Color(0xffFFEFE1)
                                          : programItem.schedule['scheduleAsRunList']['schedule']['type'][index] == irrigationProgramMainProvider.scheduleOptions[1]
                                          ? const Color(0xffE0FFF7)
                                          : programItem.schedule['scheduleAsRunList']['schedule']['type'][index] == irrigationProgramMainProvider.scheduleOptions[2]
                                          ? const Color(0xffE1F2FF)
                                          : const Color(0xffEEEBFF)
                                  )
                              else if(programItem.schedule['selected'] == irrigationProgramMainProvider.scheduleTypes[2])
                                for (var index = 0; index < (int.parse(programItem.schedule['scheduleByDays']['schedule']['runDays'].toString()) + int.parse(programItem.schedule['scheduleByDays']['schedule']['skipDays'].toString())); index++)
                                  buildScheduleMethodOfDay(
                                    method: days[index],
                                    color: index >= int.parse(programItem.schedule['scheduleByDays']['schedule']['runDays'].toString()) ? const Color(0xffFFEFE1) : const Color(0xffE1F2FF),
                                  )
                              else
                                buildScheduleMethodOfDay(
                                    method: "NOT SCHEDULED",
                                    color: Colors.grey.withOpacity(0.2)
                                )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  programItem.schedule['selected'] == irrigationProgramMainProvider.scheduleTypes[1]
                      ? "${programItem.schedule['scheduleAsRunList']['schedule']['noOfDays'].toString() == "" ? '1' : programItem.schedule['scheduleAsRunList']['schedule']['noOfDays'].toString()} day cycle"
                      : programItem.schedule['selected'] == irrigationProgramMainProvider.scheduleTypes[2]
                      ? "Run days - ${programItem.schedule['scheduleByDays']['schedule']['runDays'].toString()} \nSkip days - ${programItem.schedule['scheduleByDays']['schedule']['skipDays'].toString()}"
                      : "-",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                )
              ],
            ),
            // SizedBox(height: 5,),
            const Divider(color: Color(0xffE5DADA),),
            // SizedBox(height: 5,),
            Container(
              height: 75,
              child: Column(
                children: [
                  Container(
                    height: 65,
                    width: double.maxFinite,
                    child: (scheduleByDays || scheduleAsRunList)
                        ? GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        pageController.jumpTo(pageController.offset - details.primaryDelta! / 2);
                      },
                          child: PageView.builder(
                          controller: pageController,
                          itemCount: pageCount,
                          physics: const AlwaysScrollableScrollPhysics(),
                          onPageChanged: (int index) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              setState(() {
                                currentIndex = index;
                              });
                            });
                          },
                          itemBuilder: (context, index) {
                            return Card(
                              color: cardColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildRtcWidget(title: "RTC No", dataString: '${index+1}'),
                                    const SizedBox(width: 10,),
                                    buildRtcWidget(title: "On time", dataString: rtcType['rtc${index+1}']['onTime']),
                                    const SizedBox(width: 10,),
                                    buildRtcWidget(title: "Interval", dataString: rtcType['rtc${index+1}']['interval']),
                                    const SizedBox(width: 10,),
                                    buildRtcWidget(title: "Cycles", dataString: rtcType['rtc${index+1}']['noOfCycles']),
                                    const SizedBox(width: 10,),
                                    if(rtcType['rtc${index+1}']['stopMethod'] == irrigationProgramMainProvider.stopMethods[1])
                                      buildRtcWidget(title: "Off time", dataString: rtcType['rtc${index+1}']['offTime']),
                                    if(rtcType['rtc${index+1}']['stopMethod'] == irrigationProgramMainProvider.stopMethods[2])
                                      buildRtcWidget(title: "Max time", dataString: rtcType['rtc${index+1}']['maxTime']),
                                  ],
                                ),
                              ),
                            );
                          }
                          ),
                        )
                        : Card(
                      color: cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: const Center(child: Text("RTC not available for this method", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500),))),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for(var i = 0; i < pageCount; i++)
                          InkWell(
                            onTap: () {
                              pageController.animateToPage(i, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                            },
                            child: AnimatedContainer(
                              height: 8,
                              width: currentIndex == i ? 20 : 8,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                  color: pageCount > 1 ? currentIndex == i ? Theme.of(context).primaryColor : Colors.grey : Colors.white,
                                  // shape: BoxShape.circle
                                borderRadius: BorderRadius.circular(10)
                              ),
                              duration: const Duration(milliseconds: 200),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void createProgram(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) =>
          Consumer<IrrigationProgramProvider>(
            builder: (context, programProvider, child) {
              // print(programProvider.programLibrary!.program.where((element) => element.programName.isNotEmpty).length);
              if(programProvider.programLibrary!.program.where((element) => element.programName.isNotEmpty).length < programProvider.programLibrary!.programLimit){
                return AlertDialog(
                  title: Text("Select Program type"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: programProvider.programLibrary!.programType.map((e) {
                      return RadioListTile(
                          title: Text(e),
                          value: e,
                          groupValue: programProvider.selectedProgramType,
                          onChanged: (newValue) => programProvider.updateProgramName(newValue, 'programType'));
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          if (programProvider.selectedProgramType == 'Irrigation Program') {
                            programProvider.updateIsIrrigationProgram();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IrrigationProgram(
                                  userId: widget.userId,
                                  controllerId: widget.controllerId,
                                  serialNumber: programProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                                      ? programProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber : 0,
                                  conditionsLibraryIsNotEmpty: programProvider.conditionsLibraryIsNotEmpty,
                                  programType: programProvider.selectedProgramType,
                                  deviceId: widget.deviceId,
                                  toDashboard: false,
                                ),
                              ),
                            );
                          } else if (programProvider.selectedProgramType == 'Agitator Program') {
                            programProvider.updateIsAgitatorProgram();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IrrigationProgram(
                                  userId: widget.userId,
                                  controllerId: widget.controllerId,
                                  serialNumber: programProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                                      ? programProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber : 0,
                                  conditionsLibraryIsNotEmpty: programProvider.conditionsLibraryIsNotEmpty,
                                  programType: irrigationProgramMainProvider.selectedProgramType,
                                  deviceId: widget.deviceId,
                                  toDashboard: false,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('OK')),
                  ],
                );
              } else {
                return CustomAlertDialog(
                    title: "Alert",
                    content: "The program limit is exceeded as defined in the Product limit!",
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))
                    ]
                );
              }
            },
          ),
    );
  }

  void programCopy({required Program program, required int serialNumber, required String programType, required String programName, required String defaultProgramName}) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return AlertDialog(
                  title: const Text("Program copy!"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: copyController,
                        autofocus: true,
                        onChanged: (newValue) => tempProgramName = newValue,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: (){
                          tempProgramName = "";
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel")
                    ),
                    TextButton(
                        onPressed: (){
                          createCopyOfProgram(
                              oldSerialNumber: program.serialNumber,
                              serialNumber: serialNumber,
                              programName: tempProgramName.isEmpty ? defaultProgramName : tempProgramName,
                              defaultProgramName: defaultProgramName,
                              programType: programType
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text("OK")
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  void createCopyOfProgram({required int oldSerialNumber, required int serialNumber, required String programName, required String defaultProgramName, required String programType}) {
    irrigationProgramMainProvider
        .userProgramCopy(widget.userId, widget.controllerId, oldSerialNumber, serialNumber, programName, defaultProgramName, programType)
        .then((String message) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
    }).then((value) => irrigationProgramMainProvider.programLibraryData(widget.userId, widget.controllerId))
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: error));
    });
  }

  void showDeleteConfirmationDialog(Program program) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CustomAlertDialog(
              title: "Confirmation",
              content: 'Are you sure you want to delete?',
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    if(program.hardwareData.isEmpty) {
                      print("here");
                      deleteProgram(program);
                    } else {
                      Map<String, dynamic> deleteProgramToHardware = {
                        "3800": [{
                          "3801": "${program.serialNumber};"
                        }]
                      };
                      validatePayloadSent(
                          dialogContext: dialogContext,
                          context: context,
                          mqttPayloadProvider: mqttPayloadProvider,
                          acknowledgedFunction: () => deleteProgram(program),
                          payload: deleteProgramToHardware,
                          payloadCode: "3800",
                          deviceId: widget.deviceId
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Yes'),
                )
              ]);
        });
  }

  void handleDelete(Program program, dialogContext) async {
    try {
      var deleteProgramToHardware = {
        "3800": [{
          "3801": "${program.serialNumber};"
        }]
      };

      await MQTTManager().publish(jsonEncode(deleteProgramToHardware), "AppToFirmware/${widget.deviceId}");

      bool isAcknowledged = false;
      int maxWaitTime = 20;
      int elapsedTime = 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Please wait..."),
                ],
              ),
            ),
          );
        },
      );

      while (elapsedTime < maxWaitTime) {
        await Future.delayed(const Duration(seconds: 1));
        elapsedTime++;

        // print(mqttPayloadProvider.messageFromHw);
        if (mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['PayloadCode'] == "3800") {
          isAcknowledged = true;
          break;
        }
      }

      Navigator.of(context).pop();

      if (isAcknowledged) {
        if (mqttPayloadProvider.messageFromHw['Code'] == "200") {
          deleteProgram(program);
        } else {
          showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']}");
        }
      } else {
        showAlertDialog(message: "No acknowledgement received within 10 seconds");
      }
    } catch (error, stackTrace) {
      Navigator.of(context).pop(); // Hide loading indicator in case of error
      print("Error $error");
      print("stackTrace $stackTrace");
      showAlertDialog(message: error.toString());
    }
  }

  void showAlertDialog({required String message, Widget? child}) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: child ?? Text(message),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text("OK")
              )
            ],
          );
        }
    );
  }

  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
  }

  void deleteProgram(program) {
    irrigationProgramMainProvider
        .userProgramReset(widget.userId, widget.controllerId, program.programId, widget.deviceId, program.serialNumber, program.defaultProgramName, program.programName)
        .then((String message) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
    }).then((value) => irrigationProgramMainProvider.programLibraryData(widget.userId, widget.controllerId,))
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: error));
    });
  }

  void showEditItemDialog(program, int index) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) =>
          Consumer<IrrigationProgramProvider>(
              builder: (context, scheduleProvider, child) {
                return AlertDialog(
                  surfaceTintColor: Colors.white,
                  title: const Text('Edit Item'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: program.programName.isNotEmpty
                            ? program.programName
                            : program.defaultProgramName,
                        focusNode: _programNameFocusNode,
                        onChanged: (newValue) => program.programName = newValue,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: CustomDropdownTile(
                          showCircleAvatar: false,
                          width: 70,
                          title: 'Priority',
                          subtitle: 'Description',
                          showSubTitle: false,
                          content: Icons.priority_high,
                          dropdownItems: irrigationProgramMainProvider.priorityList.map((item) => item).toList(),
                          selectedValue: program.priority,
                          onChanged: (newValue) {
                            irrigationProgramMainProvider.updatePriority(newValue, index);
                            _programNameFocusNode.unfocus();
                          },
                          includeNoneOption: false,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        saveData(program: program);
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              }),
    );
  }

  Future<void> saveData({required Program program}) async{
    Map<String, dynamic> dataToMqtt = {
      "2800": [
        {
          "2801" : "${program.serialNumber},${program.priority == irrigationProgramMainProvider.priorityList[0] ? 1 : 0}"
        },
        {
          "2802" : widget.userId
        }
      ]
    };

    try {
      await validatePayloadSent(
      dialogContext: context,
      context: context,
      mqttPayloadProvider: mqttPayloadProvider,
      acknowledgedFunction: () {
        setState(() {
          controllerReadStatus = "1";
        });
        // showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']} from controller");
      },
      payload: dataToMqtt,
      payloadCode: "2800",
      deviceId: widget.deviceId
      ).whenComplete(() {
        if(mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['Code'] != "200") {
          print("here null");
          setState(() {
            controllerReadStatus = "0";
          });
        }
      });
      await saveProgramDetails(program);
      await Future.delayed(const Duration(seconds: 2), () async{
        await irrigationProgramMainProvider.programLibraryData(widget.userId, widget.controllerId);
      });
    } catch (error) {
      showSnackBar(message: 'Failed to update because of $error',);
      print("Error: $error");
    }
  }

  Future<void> saveProgramDetails(program) async{
    irrigationProgramMainProvider
        .updateUserProgramDetails(
        widget.userId,
        widget.controllerId,
        program.serialNumber,
        program.programId,
        program.programName,
        program.priority,
        program.defaultProgramName,
        controllerReadStatus)
        .then((value) => ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(message: value)));
  }

  void navigateToIrrigationProgram(program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IrrigationProgram(
          userId: widget.userId,
          controllerId: widget.controllerId,
          serialNumber: program.serialNumber,
          programType: program.programType,
          conditionsLibraryIsNotEmpty: irrigationProgramMainProvider.conditionsLibraryIsNotEmpty, deviceId: widget.deviceId,
          toDashboard: false,
        ),
      ),
    );
  }

  Widget buildScheduleMethodOfDay({required String method, Color? color}){
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      decoration: BoxDecoration(
          color: color ?? const Color(0xffE9F8FA),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text(method, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
    );
  }

  Widget buildRtcWidget({required String title, required String dataString}) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),),
            Text(dataString, style: const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  Widget buildIconActionWidget({
    required IconData icon,
    required Color iconColor,
    required Color containerColor,
    void Function()? onTap,
    required String toolTip,
  }) {
    return Tooltip(
      message: toolTip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 4,
                color: const Color(0xffCFCFCF).withOpacity(0.25),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget customizeGridView({required double maxWith,required double maxHeight,required double screenWidth,required List<Widget> listOfWidget}){
    var eachRowCount = (screenWidth)~/(maxWith);
    List<List<Widget>> gridWidgetRow = [];
    List<Widget> newWidgetList = [];
    for(var i = 0; i<listOfWidget.length; i++) {
      if(irrigationProgramMainProvider.selectedFilterType == 0) {
        if(irrigationProgramMainProvider.programLibrary!.program[i].programName.isNotEmpty) {
          newWidgetList.add(listOfWidget[i]);
        }
      } else {
        if(irrigationProgramMainProvider.programLibrary!.program[i].programName.isEmpty) {
          newWidgetList.add(listOfWidget[i]);
        }
      }
    }
    for(var i = 0;i < newWidgetList.length;i +=(newWidgetList.length - i) < eachRowCount ? (newWidgetList.length - i) : eachRowCount){
      List<Widget> rows = [];
      for(var j = 0;j < ((newWidgetList.length - i) < eachRowCount ? (newWidgetList.length - i) : eachRowCount);j++){
        rows.add(newWidgetList[i + j]);
      }
      gridWidgetRow.add(rows);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        for(var i = 0; i < gridWidgetRow.length; i++)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for(var widget = 0;widget < gridWidgetRow[i].length;widget++)
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: (((screenWidth) - (eachRowCount * maxWith))/eachRowCount)/2.toInt().toDouble()),
                        width: maxWith,
                        height: maxHeight,
                        child: gridWidgetRow[i][widget]
                    )
                ],
              ),
              if(i == gridWidgetRow.length - 1)
                const SizedBox(height: 50,)
            ],
          ),
      ],
    );
  }

}

Future<void> validatePayloadSent({
  required BuildContext dialogContext,
  required BuildContext context,
  required MqttPayloadProvider mqttPayloadProvider,
  required void Function() acknowledgedFunction,
  required Map<String, dynamic> payload,
  required String payloadCode,
  required String deviceId
}) async {
  try {
    await MQTTManager().publish(jsonEncode(payload), "AppToFirmware/$deviceId");

    bool isAcknowledged = false;
    int maxWaitTime = 10;
    int elapsedTime = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Please wait..."),
              ],
            ),
          ),
        );
      },
    );

    while (elapsedTime < maxWaitTime) {
      await Future.delayed(const Duration(seconds: 1));
      elapsedTime++;

      if (mqttPayloadProvider.messageFromHw != null && mqttPayloadProvider.messageFromHw['PayloadCode'] == payloadCode) {
        isAcknowledged = true;
        break;
      }
    }

    Navigator.of(context).pop();

    if (isAcknowledged) {
      if (mqttPayloadProvider.messageFromHw['Code'] == "200") {
        acknowledgedFunction();
      } else {
        showSnackBar(message: "${mqttPayloadProvider.messageFromHw['Name']}", context: context);
      }
    } else {
      showAlertDialog(message: "Controller is not responding", context: context);
    }
  } catch (error, stackTrace) {
    Navigator.of(context).pop();
    showAlertDialog(message: error.toString(), context: context);
  }
}

void showAlertDialog({required String message, Widget? child, required BuildContext context}) {
  showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: child ?? Text(message),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("OK")
            )
          ],
        );
      }
  );
}

void showSnackBar({required String message, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
}