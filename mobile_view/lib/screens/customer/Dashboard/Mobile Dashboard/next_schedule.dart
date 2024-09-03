import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/schedule_program.dart';
import 'package:provider/provider.dart';
import '../../../../ListOfFertilizerInSet.dart';
import '../../../../constants/theme.dart';
import '../../../../state_management/MqttPayloadProvider.dart';

class NextScheduleForMobile extends StatefulWidget {
  final int selectedLine;
  const NextScheduleForMobile({super.key, required this.selectedLine});

  @override
  State<NextScheduleForMobile> createState() => _NextScheduleForMobileState();
}

class _NextScheduleForMobileState extends State<NextScheduleForMobile> {
  ScrollController _nextScheduleController = ScrollController();

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return  Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Container(
            width: double.infinity,
            height: 40,
            child: Center(
              child: Text('Next Schedule',style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),),
            ),
            decoration: BoxDecoration(
                color: Color(0xffF9FAFC)
            ),
          ),
          SizedBox(height: 5,),
          if(payloadProvider.nextSchedule.isEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Image.asset('assets/images/no_data.jpg'),
            ),
          if(payloadProvider.nextSchedule.isNotEmpty)
            for(var program in payloadProvider.nextSchedule)
              if(['All',program['ProgCategory']].contains(payloadProvider.lineData[widget.selectedLine]['id']))
                Container(
                  margin: EdgeInsets.only(bottom: 20,left: 5,right: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: customBoxShadow
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: CircleAvatar(
                          backgroundColor: primaryColorDark,
                          child: Center(
                            child: Text(program['ProgName'].isNotEmpty ? program['ProgName'].substring(0, 1).toUpperCase() : '',style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        title: Text(program['ProgName'],style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                        subtitle: Text('${programSchedule[program['SchedulingMethod']]}',style: TextStyle(color: primaryColorDark,overflow: TextOverflow.ellipsis),),
                        trailing: Text('${program['ZoneName']}',style: TextStyle(color: primaryColorDark,fontWeight: FontWeight.bold,fontSize: 14,overflow: TextOverflow.ellipsis),),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for(var i in ['Zone/CurrentZone','RTC/CurrentRtc','Cycle/CurrentCycle'])
                            Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 0.5)
                            ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('${i.split('/')[0]}',style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text('${program[i.split('/')[1]]}',style: TextStyle(color: primaryColorDark),),
                                ],
                              ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: Icon(Icons.calendar_month,color: Colors.green,),
                              title: Text('Start Date',style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                              subtitle: Text('${program['StartDate']}',style: TextStyle(color: primaryColorDark,overflow: TextOverflow.ellipsis)),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: Icon(Icons.timer,color: Colors.red),
                              title: Text('Start Time',style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis)),
                              subtitle: Text('${program['StartTime']}',style: TextStyle(color: primaryColorDark,overflow: TextOverflow.ellipsis)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: Icon(Icons.location_on_outlined,color: Colors.blue,),
                              title: Text('Location',style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                              subtitle: Text('${program['ProgCategory']}',style: TextStyle(color: primaryColorDark,overflow: TextOverflow.ellipsis)),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: Icon(Icons.production_quantity_limits,color: Colors.orange),
                              title: Text('${program['IrrigationMethod'] == 1 ? 'Duration' : 'Quantity'}',style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis)),
                              subtitle: Text('${program['IrrigationDuration_Quantity']}',style: TextStyle(color: primaryColorDark,overflow: TextOverflow.ellipsis)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

var scheduleMethod = {
  1 : 'No Schedule',
  2: 'Schedule By Days',
  3 : 'Schedule As Run List',
  4 : 'Day Count RTC'
};