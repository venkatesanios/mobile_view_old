import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:oro_irrigation_new/Screens/Customer/IrrigationProgram/schedule_screen.dart';
import 'package:oro_irrigation_new/state_management/irrigation_program_main_provider.dart';
import 'package:provider/provider.dart';

import '../ScheduleView.dart';
import '../ScheduleView.dart';

class NewAlarmScreen2 extends StatefulWidget {
  const NewAlarmScreen2({super.key});

  @override
  State<NewAlarmScreen2> createState() => _NewAlarmScreen2State();
}

class _NewAlarmScreen2State extends State<NewAlarmScreen2> {
  final iconList = [
    MdiIcons.gaugeLow,
    MdiIcons.gaugeFull,
    MdiIcons.gaugeEmpty,
    MdiIcons.qualityHigh,
    MdiIcons.thermometerLow,
    MdiIcons.thermometerHigh,
    MdiIcons.speedometerSlow,
    MdiIcons.speedometer,
    MdiIcons.powerPlugOff,
    MdiIcons.signalOff,
    Icons.wrong_location,
    MdiIcons.gaugeEmpty,
    MdiIcons.gaugeFull,
    MdiIcons.batteryLow,
    MdiIcons.delta,
    Icons.difference,
    MdiIcons.pumpOff,
    Icons.difference,
  ];
  @override
  Widget build(BuildContext context) {

    return Consumer<IrrigationProgramProvider>(
        builder: (context, alarmProvider, _) {
          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                return Container(
                  margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.025),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 5),
                        child: MaterialButton(
                          // color: Colors.greenAccent.shade100,
                          // minWidth: MediaQuery.of(context).size.width - 40,
                          textColor: Colors.white,
                          elevation: 8,
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          onPressed: () {
                            setState(() {
                              for(var i = 0; i < alarmProvider.newAlarmList!.alarmList.length; i++) {
                                alarmProvider.newAlarmList!.alarmList[i].value = alarmProvider.newAlarmList!.defaultAlarm[i].value;
                              }
                            });
                          },
                          child: Text("Use global alarm".toUpperCase()),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Expanded(
                          child: ListView.builder(
                              itemCount: alarmProvider.newAlarmList!.alarmList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = alarmProvider.newAlarmList!.alarmList[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 5),
                                  child: Column(
                                    children: [
                                      buildCustomListTile(
                                          context: context,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          title: item.name,
                                          // icon: Icons.alarm,
                                          icon: iconList[index],
                                          isSwitch: true,
                                          switchValue: item.value,
                                          onSwitchChanged: (newValue) {
                                            setState(() {
                                              item.value = newValue;
                                            });
                                          }
                                      ),
                                      SizedBox(height: index == alarmProvider.newAlarmList!.alarmList.length - 1 ? 50 : 10,)
                                    ],
                                  ),
                                );
                              }
                          )
                      )
                    ],
                  ),
                );
              }
          );
        }
    );
  }
}
