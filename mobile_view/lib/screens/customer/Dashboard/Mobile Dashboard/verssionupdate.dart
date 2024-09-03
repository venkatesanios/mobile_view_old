import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../constants/theme.dart';
import '../../../../state_management/overall_use.dart';
import 'package:provider/provider.dart';


class ResetVerssion extends StatefulWidget {
  @override
  _ResetVerssionState createState() => _ResetVerssionState();
}

class _ResetVerssionState extends State<ResetVerssion> {

  List<Map<String, dynamic>> mergedList = [];

  valAssing(List<dynamic> data )
  {
    for (var group in data) {
      var userGroupId = group['userGroupId'];
      var groupName = group['groupName'];
      var active = group['active'];
      var masterList = group['master'];

      for (var device in masterList) {
        mergedList.add({
          'userGroupId': userGroupId,
          'groupName': groupName,
          'active': active,
          'controllerId': device['controllerId'],
          'deviceId': device['deviceId'],
          'deviceName': device['deviceName'],
          'categoryId': device['categoryId'],
          'categoryName': device['categoryName'],
          'modelId': device['modelId'],
          'modelName': device['modelName'],
          'latestVersion': device['latestVersion'] ?? '',
          'currentVersion': device['currentVersion'] ?? '',
        });
      }
    }
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    Map<String, Object> body = {
      "userId": overAllPvd.userId
    };
    final response = await HttpService()
        .postRequest("getUserDeviceFirmwareDetails", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        valAssing(jsondata1['data']);
        MQTTManager().connect();
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void resetItem(int index) {
    setState(() {
      ResetAll();
    });
  }

  void updateItem(int index) {
    setState(() {
      Update();
    });
  }
  ResetAll()   {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    String payLoadFinal = jsonEncode({
      "5700": [
        {"5701": "2"},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
  }
  Update()   {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    String payLoadFinal = jsonEncode({
      "5700": [
        {"5701": "3"},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      appBar: AppBar(
        title: Text('Controller Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 40,
            mainAxisSpacing: 40,
          ),
          padding: EdgeInsets.all(10),
          itemCount: mergedList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: 10),
                  Text(
                    mergedList[index]['categoryName']!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 1,color: Colors.black,),
                  SizedBox(height: 20,),
                  Text(
                    mergedList[index]['deviceId']!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('SiteNane:${mergedList[index]['groupName'] ?? ''}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),

                  SizedBox(height: 10),
                  Text('Model:${mergedList[index]['modelName'] ?? ''}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10),
                  Text('Controller version:${mergedList[index]['currentVersion'] ?? ''}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10),
                  Text('Latest version:${mergedList[index]['latestVersion']!}',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10),
                  Container(height: 1,color: Colors.grey,),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FilledButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                          onPressed: () => resetItem(index),
                          child: Text('Reset'),
                        ),
                        SizedBox(width: 10),
                        FilledButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: () => updateItem(index),
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
