import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/program_library.dart';
import 'package:mobile_view/state_management/overall_use.dart';

import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/MQTTManager.dart';
import '../../../../../constants/theme.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';

import 'NodeHourlyLog/node_horuly_log.dart';
import 'SensorLogData/sensor_log_data.dart';

class NodeStatus extends StatefulWidget {
  const NodeStatus({super.key});

  @override
  State<NodeStatus> createState() => _NodeStatusState();
}

class _NodeStatusState extends State<NodeStatus> {
  late MqttPayloadProvider payloadProvider;
  late OverAllUse overAllPvd;

  @override
  void initState() {
    // TODO: implement initState
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    // Map<String, dynamic> data = jsonDecode(provider.receivedDashboardPayload);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);

    return payloadProvider.nodeData.isNotEmpty ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 50,),
            // CircleAvatar(
            //   radius: 30,
            //   backgroundColor:myTheme.primaryColorDark.withOpacity(0.2),
            //   child: Image.asset('assets/images/oro_gem.png', width: 40, height: 40,),
            // ),
            // Text(deviceData["deviceName"], style: const TextStyle(color: Colors.black, fontSize: 13)),
            // Text('${deviceData["categoryName"]} - Last sync : ${payloadProvider.lastUpdate.day}/${payloadProvider.lastUpdate.month}/${payloadProvider.lastUpdate.year} ${payloadProvider.lastUpdate.hour}:${payloadProvider.lastUpdate.minute}:${payloadProvider.lastUpdate.second}', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: Colors.black,),),
            ListTile(
              title: Text("Node List".toUpperCase()),
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              trailing: IntrinsicWidth(
                child: Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => NodeHrsLog(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId,))
                          );
                        },
                        icon: Icon(Icons.auto_graph, color: Colors.deepOrangeAccent,)
                    ),
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => SensorHourlyLogs(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId,))
                          );
                        },
                        icon: Icon(Icons.sensors, color: Colors.blueGrey,)
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 5),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 5),
                              CircleAvatar(radius: 5, backgroundColor: Colors.green,),
                              SizedBox(width: 5),
                              Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 5),
                              CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                              SizedBox(width: 5),
                              Text('No Communication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              CircleAvatar(radius: 5, backgroundColor: Colors.redAccent,),
                              SizedBox(width: 5),
                              Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 10),
                              CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                              SizedBox(width: 5),
                              Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          tooltip: 'Set serial for all Nodes',
                          icon: Icon(Icons.format_list_numbered, color: myTheme.primaryColorDark),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text('Are you sure! you want to proceed to reset all node ids?'),
                                  actions: <Widget>[
                                    MaterialButton(
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    MaterialButton(
                                      color: myTheme.primaryColor,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Map<String, dynamic> payLoadFinal = {
                                          "2300": [
                                            {"2301": ""},
                                          ]
                                        };
                                        validatePayloadSent(
                                            dialogContext: context,
                                            context: context,
                                            mqttPayloadProvider: payloadProvider,
                                            acknowledgedFunction: () {
                                              showSnackBar(message: "${payloadProvider.messageFromHw['Code'] == 200 ? "Set serial for all Nodes successfully" : payloadProvider.messageFromHw['Name']}", context: context);
                                            },
                                            payload: payLoadFinal,
                                            payloadCode: '2300',
                                            deviceId: '${overAllPvd.imeiNo}'
                                        );
                                        // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
                                        // GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                                        Navigator.of(dialogContext).pop();
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          tooltip: 'Test Communication',
                          icon: Icon(Icons.network_check, color: myTheme.primaryColorDark),
                          onPressed: () async {
                            Map<String, dynamic> payLoadFinal = {
                              "4500": [
                                {"4501": ""},
                              ]
                            };
                            validatePayloadSent(
                                dialogContext: context,
                                context: context,
                                mqttPayloadProvider: payloadProvider,
                                acknowledgedFunction: () {
                                  showSnackBar(message: "${payloadProvider.messageFromHw['Code'] == 200 ? "Test Communication successfully" : payloadProvider.messageFromHw['Name']}", context: context);
                                },
                                payload: payLoadFinal,
                                payloadCode: '4500',
                                deviceId: '${overAllPvd.imeiNo}'
                            );
                            // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
                            // GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                            // Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width-20,
                height: MediaQuery.sizeOf(context).height-230,
                child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 325,
                    dataRowHeight: 55.0,
                    headingRowHeight: 35.0,
                    headingRowColor: MaterialStateProperty.all<Color>(myTheme.primaryColorDark.withOpacity(0.2)),
                    columns: const [
                      DataColumn2(
                          label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                          fixedWidth: 35
                      ),
                      DataColumn2(
                        label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                        fixedWidth: 55,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Rf.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                        fixedWidth: 45,
                      ),
                      DataColumn2(
                        label: Text('Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                        size: ColumnSize.M,
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                        fixedWidth: 40,
                      ),
                    ],
                    rows: List<DataRow>.generate(payloadProvider.nodeData.length, (index) => DataRow(cells: [
                      DataCell(Center(child: Text('${payloadProvider.nodeData[index].serialNumber}', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),))),
                      DataCell(Center(child: CircleAvatar(radius: 7,
                        backgroundColor:
                        payloadProvider.nodeData[index].status == 1
                            ? Colors.green.shade400
                            : payloadProvider.nodeData[index].status == 2
                            ? Colors.grey
                            : payloadProvider.nodeData[index].status == 3
                            ? Colors.redAccent
                            : payloadProvider.nodeData[index].status == 4
                            ? Colors.yellow
                            : Colors.grey,
                      ))),
                      DataCell(Center(child: Text('${payloadProvider.nodeData[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)))),
                      DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(payloadProvider.nodeData[index].categoryName ?? "", style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
                              Text(payloadProvider.nodeData[index].deviceId.toString(), style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.black)),
                            ],
                          )),
                      DataCell(Center(child: IconButton(tooltip: 'View Relay status',
                        icon: payloadProvider.nodeData[index].rlyStatus.any((rly) => rly == 2 || rly == 3)
                            ? const Icon(Icons.warning, color: Colors.orangeAccent)
                            : Icon(Icons.info_outline, color: myTheme.primaryColorDark),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    tileColor: myTheme.primaryColor,
                                    textColor: Colors.white,
                                    leading: const Icon(Icons.developer_board_rounded, color: Colors.white),
                                    title: Text('${payloadProvider.nodeData[index].categoryName} - ${payloadProvider.nodeData[index].deviceId.toString()}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.solar_power_outlined, color: Colors.white),
                                        const SizedBox(width: 5,),
                                        Text('${payloadProvider.nodeData[index].slrVolt.toString()} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                        const SizedBox(width: 5,),
                                        const Icon(Icons.battery_3_bar_rounded, color: Colors.white),
                                        const SizedBox(width: 5,),
                                        Text('${payloadProvider.nodeData[index].batVolt.toString()} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                        const SizedBox(width: 5,),
                                        IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                          Map<String, dynamic> payLoadFinal = {
                                            "2300": [
                                              {"2301": "${payloadProvider.nodeData[index].serialNumber.toString()}"},
                                            ]
                                          };
                                          validatePayloadSent(
                                              dialogContext: context,
                                              context: context,
                                              mqttPayloadProvider: payloadProvider,
                                              acknowledgedFunction: () {
                                                showSnackBar(message: "${payloadProvider.messageFromHw['Code'] == 200 ? "Serial set for all Relay successfully" : payloadProvider.messageFromHw['Name']}", context: context);
                                              },
                                              payload: payLoadFinal,
                                              payloadCode: '2300',
                                              deviceId: '${overAllPvd.imeiNo}'
                                          );
                                        }, icon: Icon(Icons.fact_check_outlined, color: Colors.white))
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 0),
                                  payloadProvider.nodeData[index].rlyStatus.isNotEmpty ? Expanded(
                                    child: Column(
                                      mainAxisSize : MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(radius: 5,backgroundColor: Colors.green,),
                                                  SizedBox(width: 5),
                                                  Text('ON'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(radius: 5,backgroundColor: Colors.black45,),
                                                  SizedBox(width: 5),
                                                  Text('OFF'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(radius: 5,backgroundColor: Colors.orange,),
                                                  SizedBox(width: 5),
                                                  Text('ON IN OFF'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(radius: 5,backgroundColor: Colors.redAccent,),
                                                  SizedBox(width: 5),
                                                  Text('OFF IN ON'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Expanded(
                                          child: GridView.builder(
                                            itemCount: payloadProvider.nodeData[index].rlyStatus.length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 5,
                                              crossAxisSpacing: 20.0,
                                              mainAxisSpacing: 20.0,
                                            ),
                                            itemBuilder: (BuildContext context, int indexGv) {
                                              //print(widget.siteData.nodeList[index].rlyStatus[indexGv].s);
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: payloadProvider.nodeData[index].rlyStatus[indexGv].status==0 ? Colors.grey :
                                                    payloadProvider.nodeData[index].rlyStatus[indexGv].status ==1 ? Colors.green :
                                                    payloadProvider.nodeData[index].rlyStatus[indexGv].status ==2 ? Colors.orange :
                                                    payloadProvider.nodeData[index].rlyStatus[indexGv].status ==3 ? Colors.redAccent : Colors.black12,
                                                    child: Text((payloadProvider.nodeData[index].rlyStatus[indexGv].rlyNo).toString(), style: const TextStyle(color: Colors.white)),
                                                  ),
                                                  Text((payloadProvider.nodeData[index].rlyStatus[indexGv].name).toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) :
                                  Expanded(child: const Center(child: Text('Relay Status Not Found'))),
                                ],
                              );
                            },
                          );
                        },
                        // icon: Icon(CupertinoIcons.zoom_in),
                      ))),
                    ]))
                      ..add(DataRow(cells: [
                        DataCell(Center(child: Text('', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),))),
                        DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor: Colors.transparent))),
                        DataCell(Center(child: Text('', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)))),
                        DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
                                Text('', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: Colors.black)),
                              ],
                            )
                        ),
                        DataCell(Center(child: IconButton(
                          tooltip: '',
                          icon: Icon(Icons.info_outline, color: Colors.transparent),
                          onPressed: () {},
                        ))),
                      ]))
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: customBoxShadow
            ),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.keyboard_double_arrow_left),
                Text('Go Back'),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    ):
    Container(
        height: MediaQuery.sizeOf(context).height,
        width: 400,
        color: Colors.white,
        child: const Center(child: Text('Loading data...'))
    );
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
      print(stackTrace);
      showAlertDialog(message: error.toString(), context: context);
    }
  }
}
