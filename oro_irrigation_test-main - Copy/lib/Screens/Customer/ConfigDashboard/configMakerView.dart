import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/central_dosing_view.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/central_filtration_view.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/irrigationLineView.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/pumpView.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/weather_station_view.dart';

import '../../../constants/http_service.dart';
import 'oro_system.dart';
import 'others_view.dart';

class ConfigMakerView extends StatefulWidget {
  const ConfigMakerView({super.key, required this.userID, required this.customerID, required this.siteID});
  final int userID, customerID, siteID;

  @override
  State<ConfigMakerView> createState() => _ConfigMakerViewState();
}

class _ConfigMakerViewState extends State<ConfigMakerView> {
  dynamic sourcePump = [];
  dynamic irrigationPump = [];
  dynamic centralDosing = [];
  dynamic centralFiltration = [];
  dynamic irrigationLines = [];
  dynamic weatherStation = [];
  dynamic others = {};
  dynamic referenceList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // MqttWebClient().init();
    getData();
  }

  void getName(data,nameData){
    for(var d in data){
      loopCut : for(var dName in nameData){
        for(var name in dName['userName']){
          if(d['sNo'] == name['sNo']){
            setState(() {
              d['name'] = name['name'];
            });
            break loopCut;
          }
        }
      }
    }
  }

  Future<void> getData() async {
    // constantPvd.sendDataToHW();
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserConfigMaker', {'userId' : widget.customerID,'controllerId' : widget.siteID});
      var names = await service.postRequest('getUserName', {'userId' : widget.customerID,'controllerId' : widget.siteID});
      var preference = await service.postRequest('getUserPreference', {'userId' : widget.customerID,'controllerId' : widget.siteID});
      var namesData = jsonDecode(names.body);
      print('mynames : ${jsonEncode(namesData)}');
      var jsonData = jsonDecode(response.body);
      print('myjson : ${jsonData}');
      setState(() {
        if(jsonData['data']['referenceNo']['3'] != null){
          referenceList.add({'name' : 'PUMP','count' : jsonData['data']['referenceNo']['3'].length});
        }
        if(jsonData['data']['referenceNo']['4'] != null){
          referenceList.add({'name' : 'PUMP-PLUS','count' : jsonData['data']['referenceNo']['4'].length});
        }
        if(jsonData['data']['referenceNo']['6'] != null){
          referenceList.add({'name' : 'LEVEL','count' : jsonData['data']['referenceNo']['6'].length});
        }
        if(jsonData['data']['referenceNo']['7'] != null){
          referenceList.add({'name' : 'SMART-PLUS','count' : jsonData['data']['referenceNo']['7'].length});
        }
        if(jsonData['data']['referenceNo']['8'] != null){
          referenceList.add({'name' : 'RTU-PLUS','count' : jsonData['data']['referenceNo']['8'].length});
        }
        if(jsonData['data']['referenceNo']['9'] != null){
          referenceList.add({'name' : 'SWITCH','count' : jsonData['data']['referenceNo']['9'].length});
        }
        if(jsonData['data']['referenceNo']['12'] != null){
          referenceList.add({'name' : 'SMART','count' : jsonData['data']['referenceNo']['12'].length});
        }
        if(jsonData['data']['referenceNo']['13'] != null){
          referenceList.add({'name' : 'RTU','count' : jsonData['data']['referenceNo']['13'].length});
        }
        if(jsonData['data']['referenceNo']['10'] != null){
          referenceList.add({'name' : 'SENSE','count' : jsonData['data']['referenceNo']['10'].length});
        }
        if(jsonData['data']['referenceNo']['11'] != null){
          referenceList.add({'name' : 'EXTEND','count' : jsonData['data']['referenceNo']['11'].length});
        }
        for(var pump in jsonData['data']['configMaker']['sourcePump']){
          sp : for(var pumpName in namesData['data']){
            for(var name in pumpName['userName']){
              if(pump['sNo'] == name['sNo']){
                pump['name'] = name['name'];
                pump['visible'] = true;
                setState(() {
                  sourcePump.add(pump);
                });
                break sp;
              }
            }
          }
        }
        for(var pump in jsonData['data']['configMaker']['irrigationPump']){
          sp : for(var pumpName in namesData['data']){
            for(var name in pumpName['userName']){
              if(pump['sNo'] == name['sNo']){
                pump['name'] = name['name'];
                pump['visible'] = true;
                setState(() {
                  irrigationPump.add(pump);
                });
                break sp;
              }
            }
          }
        }
        others['connTempSensor'] = jsonData['data']['configMaker']['productLimit']['connTempSensor'];
        others['connTempSensorVisible'] = true;
        getName(others['connTempSensor'],namesData['data']);
        others['connSoilTempSensor'] = jsonData['data']['configMaker']['productLimit']['connSoilTempSensor'];
        getName(others['connSoilTempSensor'],namesData['data']);
        others['connSoilTempSensorVisible'] = true;
        others['connHumidity'] = jsonData['data']['configMaker']['productLimit']['connHumidity'];
        getName(others['connHumidity'],namesData['data']);
        others['connHumidityVisible'] = true;
        others['connCo2'] = jsonData['data']['configMaker']['productLimit']['connCo2'];
        getName(others['connCo2'],namesData['data']);
        others['connCo2Visible'] = true;
        others['connLux'] = jsonData['data']['configMaker']['productLimit']['connLux'];
        getName(others['connLux'],namesData['data']);
        others['connLuxVisible'] = true;
        others['connLdr'] = jsonData['data']['configMaker']['productLimit']['connLdr'];
        getName(others['connLdr'],namesData['data']);
        others['connLdrVisible'] = true;
        others['connWindSpeed'] = jsonData['data']['configMaker']['productLimit']['connWindSpeed'];
        getName(others['connWindSpeed'],namesData['data']);
        others['connWindSpeedVisible'] = true;
        others['connWindDirection'] = jsonData['data']['configMaker']['productLimit']['connWindDirection'];
        getName(others['connWindDirection'],namesData['data']);
        others['connWindDirectionVisible'] = true;
        others['connRainGauge'] = jsonData['data']['configMaker']['productLimit']['connRainGauge'];
        getName(others['connRainGauge'],namesData['data']);
        others['connRainGaugeVisible'] = true;
        others['connLeafWetness'] = jsonData['data']['configMaker']['productLimit']['connLeafWetness'];
        getName(others['connLeafWetness'],namesData['data']);
        others['connLeafWetnessVisible'] = true;
        others['totalAnalogSensor'] = jsonData['data']['configMaker']['productLimit']['totalAnalogSensor'];
        getName(others['totalAnalogSensor'],namesData['data']);
        others['totalAnalogSensorVisible'] = true;
        others['totalContact'] = jsonData['data']['configMaker']['productLimit']['totalContact'];
        getName(others['totalContact'],namesData['data']);
        others['totalContactVisible'] = true;
        others['totalAgitator'] = jsonData['data']['configMaker']['productLimit']['totalAgitator'];
        getName(others['totalAgitator'],namesData['data']);
        others['totalAgitatorVisible'] = true;
        others['totalSelector'] = jsonData['data']['configMaker']['productLimit']['totalSelector'];
        getName(others['totalSelector'],namesData['data']);
        others['totalSelectorVisible'] = true;
        irrigationLines = jsonData['data']['configMaker']['irrigationLine'];
        getName(irrigationLines,namesData['data']);
        for(var line in irrigationLines){
          line['visible'] = true;
          line['valveVisible'] = true;
          line['mvVisible'] = true;
          line['fanVisible'] = true;
          line['foggerVisible'] = true;
          line['filterVisible'] = true;
          line['dvVisible'] = true;
          line['boosterVisible'] = true;
          line['injectorVisible'] = true;
          line['dmVisible'] = true;
          line['levelVisible'] = true;
          line['ecVisible'] = true;
          line['phVisible'] = true;
          line['psVisible'] = true;
          line['pSwitchVisible'] = true;
          line['wmVisible'] = true;
          if(line['Local_dosing_site'] == true){
            for(var ld in jsonData['data']['configMaker']['localFertilizer']){
              if(ld['sNo'] == line['sNo']){
                line['injector'] = ld['injector'];
                line['ld_pressureSwitch'] = ld['pressureSwitch'];
                line['boosterConnection'] = ld['boosterConnection'];
                line['ecConnection'] = ld['ecConnection'];
                line['phConnection'] = ld['phConnection'];
                for(var dm in ld['injector']){
                  line['dosingMeter'] = dm['dosingMeter'];
                  line['levelSensorConnection'].add(dm['levelSensor']);
                }
              }
            }
          }
          if(line['local_filtration_site'] == true){
            for(var lf in jsonData['data']['configMaker']['localFilter']){
              if(lf['sNo'] == line['sNo']){
                print('filter true');
                line['filterConnection'] = lf['filterConnection'];
                line['dv'] = lf['dv'];
                line['lf_pressureIn'] = lf['pressureIn'];
                line['lf_pressureOut'] = lf['pressureOut'];
                line['lf_pressureSwitch'] = lf['pressureSwitch'];
                line['diffPressureSensor'] = lf['diffPressureSensor'];
              }
            }
          }
          getName(line['valveConnection'],namesData['data']);
          getName(line['main_valveConnection'],namesData['data']);
          getName(line['moistureSensorConnection'],namesData['data']);
          getName(line['levelSensorConnection'],namesData['data']);
          getName(line['foggerConnection'],namesData['data']);
          getName(line['fanConnection'],namesData['data']);
          if(line['Local_dosing_site'] == true){
            getName(line['injector'],namesData['data']);
            getName(line['boosterConnection'],namesData['data']);
            getName(line['ecConnection'],namesData['data']);
            getName(line['phConnection'],namesData['data']);
            getName([line['dosingMeter']],namesData['data']);
            getName([line['ld_pressureSwitch']],namesData['data']);
          }
          if(line['local_filtration_site'] == true){
            getName(line['filterConnection'],namesData['data']);
            getName([line['lf_pressureIn']],namesData['data']);
            getName([line['dv']],namesData['data']);
            getName([line['lf_pressureIn']],namesData['data']);
            getName([line['lf_pressureOut']],namesData['data']);
            getName([line['lf_pressureSwitch']],namesData['data']);
            getName([line['diffPressureSensor']],namesData['data']);
          }
          getName([line['pressureIn']],namesData['data']);
          getName([line['pressureOut']],namesData['data']);
          getName([line['water_meter']],namesData['data']);
        }
        centralDosing = jsonData['data']['configMaker']['centralFertilizer'];

        getName(centralDosing,namesData['data']);
        for(var cd in centralDosing){
          cd['visible'] = true;
          cd['injectorVisible'] = true;
          cd['dmVisible'] = true;
          cd['levelVisible'] = true;
          cd['boosterVisible'] = true;
          cd['ecVisible'] = true;
          cd['phVisible'] = true;
          cd['pSwitchVisible'] = true;
          getName(cd['injector'],namesData['data']);
          for(var dm in cd['injector']){
            getName([dm['dosingMeter']],namesData['data']);
          }
          getName(cd['boosterConnection'],namesData['data']);
          getName(cd['ecConnection'],namesData['data']);
          getName(cd['phConnection'],namesData['data']);
          getName([cd['pressureSwitch']],namesData['data']);
        }
        centralFiltration = jsonData['data']['configMaker']['centralFilter'];
        for(var cf in centralFiltration){
          cf['visible'] = true;
          cf['filterVisible'] = true;
          cf['dvVisible'] = true;
          cf['psVisible'] = true;
          cf['pSwitchVisible'] = true;
          getName(cf['filterConnection'],namesData['data']);
          getName([cf['pressureIn']],namesData['data']);
          getName([cf['pressureOut']],namesData['data']);
          getName([cf['pressureSwitch']],namesData['data']);
          getName([cf['diffPressureSensor']],namesData['data']);
        }
        irrigationLines = jsonData['data']['configMaker']['irrigationLine'];
        weatherStation = jsonData['data']['configMaker']['weatherStation'];

      });

    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('ConfigMaker View'),
      ),
      body: DefaultTabController(
        length: 8,
        child: Column(
          children: [
            TabBar(
                tabs: [
                  Tab(
                    child: Text('Gem'),
                  ),
                  Tab(
                    child: Text('Source pump'),
                  ),
                  Tab(
                    child: Text('Irrigation pump'),
                  ),
                  Tab(
                    child: Text('Dosing site'),
                  ),
                  Tab(
                    child: Text('Filtration site'),
                  ),
                  Tab(
                    child: Text('Lines'),
                  ),
                  Tab(
                    child: Text('Weather Station'),
                  ),
                  Tab(
                    child: Text('Others'),
                  ),

                ]
            ),
            Expanded(
                child: Container(
                  child: TabBarView(
                    children: [
                      LayoutBuilder(
                        builder: (context,constraints){
                          return Center(child: ConnectedCircles(list: referenceList,));
                        },
                      ),
                      PumpView(sourcePump: sourcePump,),
                      PumpView(sourcePump: irrigationPump,),
                      CentralDosingView(centralDosing: centralDosing),
                      CentralFiltrationView(centralFiltration: centralFiltration),
                      IrrigationLinesView(irrigationLine: irrigationLines),
                      WeatherStationView(weatherStation: weatherStation),
                      OthersView(others: others)

                    ],
                  ),
                )
            )
          ],
        ),
      ),
      // body : LayoutBuilder(
      //   builder: (context,constraints){
      //     return Center(child: ConnectedCircles());
      //   },
      // ),
    );
  }
}
