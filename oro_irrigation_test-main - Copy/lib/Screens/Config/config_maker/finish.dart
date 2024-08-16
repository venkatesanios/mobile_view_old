import 'dart:convert' as convert;
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';
import '../../../Models/create_json_file.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/config_maker_provider.dart';

enum HttpMqttStatus {payloadConversionFailed,mqttFailed,httpFailed,success}
class FinishPageConfigMaker extends StatefulWidget {
  const FinishPageConfigMaker({super.key, required this.userId, required this.customerID, required this.controllerId,required this.imeiNo});
  final int userId, controllerId, customerID;
  final String imeiNo;

  @override
  State<FinishPageConfigMaker> createState() => _FinishPageConfigMakerState();
}

class _FinishPageConfigMakerState extends State<FinishPageConfigMaker> {
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    var payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    return Container(
      color: const Color(0xFFF3F3F3),
      child: Center(
        child: Row(
          children: [
            InkWell(
              onTap: ()async{
                showDialog(context: context, builder: (context){
                  return Consumer<ConfigMakerProvider>(builder: (context,configPvd,child){
                    for(var i in configPvd.irrigationLines){
                      if(i['irrigationPump'] == '-'){
                        return AlertDialog(
                          title: const Text('Please assign Irrigation Pump For all line',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                          content: const Text('Click ok to go Irrigation Line tab',style: TextStyle(fontSize: 14)),
                          actions: [
                            InkWell(
                              onTap: (){
                                configPvd.editSelectedTab(5);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 80,
                                height: 30,
                                color: myTheme.primaryColor,
                                child: const Center(
                                  child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return AlertDialog(
                      title: Text(configPvd.wantToSendData == 0
                          ? 'Send to server' : configPvd.wantToSendData == 1
                          ?  'Sending.....' : configPvd.wantToSendData == 2
                          ? 'Success...' : configPvd.wantToSendData == 3
                          ? 'No Internet' : configPvd.wantToSendData == 4
                          ? 'Mqtt Error' : 'Payload Conversion Failed.....',style: TextStyle(color: (configPvd.wantToSendData == 3 || configPvd.wantToSendData == 4) ? Colors.red : Colors.green),),
                      content: configPvd.wantToSendData == 0
                          ? const Text('Are you sure want to send data ? ')
                          : SizedBox(
                        width: 200,
                        height: 200,
                        child: configPvd.wantToSendData == 2
                            ? Image.asset('assets/images/success.png')
                            : configPvd.wantToSendData == 3
                            ? Image.asset('assets/images/serverError.png')
                            : configPvd.wantToSendData == 4
                            ? Image.asset('assets/images/mqttError.png')
                            : configPvd.wantToSendData == 5
                            ? Image.asset('assets/images/payload_conversion_failed.png')
                            :const LoadingIndicator(
                          indicatorType: Indicator.pacman,
                        ),
                      ),
                      actions: [
                        if(configPvd.wantToSendData == 0)
                          InkWell(
                            onTap: (){
                              payloadFunction(configPvd: configPvd, payloadProvider: payloadProvider, payloadFromStart: true);
                            },
                            child: Container(
                              // width: 80,
                              // height: 30,
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              color: myTheme.primaryColor,
                              child: const Center(
                                child: Text('send all payload',style: TextStyle(color: Colors.white,fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        if(configPvd.wantToSendData == 0)
                          InkWell(
                            onTap: (){
                              payloadFunction(configPvd: configPvd, payloadProvider: payloadProvider, payloadFromStart: false);
                            },
                            child: Container(
                              // width: 80,
                              // height: 30,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              color: myTheme.primaryColor,
                              child: const Center(
                                child: Text('send only unsended payload',style: TextStyle(color: Colors.white,fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        if([2,3,4,5].contains(configPvd.wantToSendData))
                          InkWell(
                            onTap: (){
                              configPvd.editWantToSendData(0);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 80,
                              height: 30,
                              color: myTheme.primaryColor,
                              child: const Center(
                                child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                ),
                              ),
                            ),
                          )
                      ],
                    );
                  });

                });
              },
              child: Container(
                width: 250,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: configPvd.flag == '0' ? Colors.yellow : Colors.green,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset('assets/images/sendToServer.png')),
                    const Text('Send',style: TextStyle(fontSize: 20,color: Colors.black),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void payloadFunction({
    required ConfigMakerProvider configPvd,
    required MqttPayloadProvider payloadProvider,
    required bool payloadFromStart
})async{
    var newPayload = {};
    HttpMqttStatus status = HttpMqttStatus.success;
    configPvd.editWantToSendData(1);
    //Todo Gem Payload Conversion
    if([1,2].contains(configPvd.categoryId)){
      try{
        newPayload[widget.imeiNo] = {
          'payload' : convert.jsonEncode(configPvd.sendData()),
          'code' : '400',
          'message' : '',
          'macAddress' : widget.imeiNo,
          'checkingCode' : '200',
        };
      }catch(e){
        if (kDebugMode) {
          print('Error on gem Payload Conversion Failed => \n'
              ' ${e.toString()}\n'
              '------------------------------------------------------------------------------------------');
        }
        status = HttpMqttStatus.payloadConversionFailed;
      }

    }
    //Todo OroPump Payload Conversion
    if(status == HttpMqttStatus.success){
      if(configPvd.serverData['referenceNo'].containsKey('3')){
        try{
          for(var oroPump in configPvd.serverData['referenceNo']['3']){
            var pumpCount = 0;
            String masterSlave = '';
            for(var pump in configPvd.sourcePumpUpdated){
              if(pump['deleted'] == false){
                if(pump['rtu'] == 'ORO Pump'){
                  if(pump['rfNo'] == oroPump['referenceNumber'].toString()){
                    masterSlave += '${masterSlave.isNotEmpty ? ',' : ''}${1}';
                    pumpCount += 1;
                  }
                }
              }
            }
            for(var pump in configPvd.irrigationPumpUpdated){
              if(pump['deleted'] == false){
                if(pump['rtu'] == 'ORO Pump'){
                  if(pump['rfNo'] == oroPump['referenceNumber'].toString()){
                    masterSlave += '${masterSlave.isNotEmpty ? ',' : ''}${2}';
                    pumpCount += 1;
                  }
                }
              }
            }
            if(pumpCount != 0){
              var actualPumpPayload = convert.jsonEncode({"sentSms":"pumpconfig,$pumpCount,${oroPump['referenceNumber']},$masterSlave"});
              var gemPumpPayload = convert.jsonEncode({
                '5900' : [
                  {
                    '5901' : '${oroPump['serialNumber']}+'
                        '${oroPump['referenceNumber']}+'
                        '${oroPump['deviceId']}+'
                        '${oroPump['interfaceTypeId']}+'
                        '${convert.jsonEncode({'700' : actualPumpPayload})}'
                  }
                ]
              });
              newPayload['${oroPump['deviceId']}-pumpconfig'] = {
                'payload' : [1,2].contains(configPvd.categoryId) ? gemPumpPayload : actualPumpPayload,
                'code' : '400',
                'message' : '',
                'macAddress' : [1,2].contains(configPvd.categoryId) ? widget.imeiNo : '${oroPump['deviceId']}',
                'checkingCode' : '700',
              };
            }
          }
        }catch(e){
          if (kDebugMode) {
            print('Error on OroPump Payload Conversion Failed => \n'
                ' ${e.toString()}\n'
                '------------------------------------------------------------------------------------------');
            status = HttpMqttStatus.payloadConversionFailed;
          }
        }

      }
    }
    //Todo OroPumpPlus Payload Conversion
    if(status == HttpMqttStatus.success){
      if(configPvd.serverData['referenceNo'].containsKey('4')){
        try{
          for(var oroPumpPlus in configPvd.serverData['referenceNo']['4']){
            int pumpCount = 0;
            String masterSlave = '';
            String tankPayLoad = '';
            for(var pump in configPvd.sourcePumpUpdated){
              if(pump['deleted'] == false){
                if(pump['rtu'] == (configPvd.categoryId == 3 ? 'ORO Pump' : 'O-Pump-Plus')){
                  int tankPin = 0;
                  int sumpPin = 0;
                  int highTankPin = 0;
                  int lowTankPin = 0;
                  int highSumpPin = 0;
                  int lowSumpPin = 0;
                  int levelSensor = 0;
                  int pressureSensor = 0;
                  int waterMeter = 0;
                  if(pump['rfNo'] == oroPumpPlus['referenceNumber'].toString()){
                    masterSlave += '${masterSlave.isNotEmpty ? ',' : ''}${1}';
                    pumpCount += 1;
                    if(pump['TopTankHigh'].isNotEmpty){
                      highTankPin = pump['TopTankHigh']['input'] == '-' ? 0 : int.parse(pump['TopTankHigh']['input'].split('-')[1]);
                      tankPin += 1;
                    }
                    if(pump['TopTankLow'].isNotEmpty){
                      lowTankPin = pump['TopTankLow']['input'] == '-' ? 0 : int.parse(pump['TopTankLow']['input'].split('-')[1]);
                      tankPin += 1;
                    }
                    if(pump['SumpTankHigh'].isNotEmpty){
                      highSumpPin = pump['SumpTankHigh']['input'] == '-' ? 0 : int.parse(pump['SumpTankHigh']['input'].split('-')[1]);
                      sumpPin += 1;
                    }
                    if(pump['SumpTankLow'].isNotEmpty){
                      lowSumpPin = pump['SumpTankLow']['input'] == '-' ? 0 : int.parse(pump['SumpTankLow']['input'].split('-')[1]);
                      sumpPin += 1;
                    }
                    if(pump['levelSensor'].isNotEmpty){
                      levelSensor = 1;
                    }
                    if(pump['pressureSensor'].isNotEmpty){
                      pressureSensor = 1;
                    }
                    if(pump['waterMeter'].isNotEmpty){
                      waterMeter = 1;
                    }
                    tankPayLoad += '$sumpPin,$lowSumpPin,$highSumpPin,$tankPin,$lowTankPin,$highTankPin,$levelSensor,$waterMeter,$pressureSensor,';
                  }
                }
              }

            }
            for(var pump in configPvd.irrigationPumpUpdated){
              if(pump['deleted'] == false){
                if(pump['rtu'] == (configPvd.categoryId == 3 ? 'ORO Pump' : 'O-Pump-Plus')){
                  var tankPin = 0;
                  var sumpPin = 0;
                  var highTankPin = 0;
                  var lowTankPin = 0;
                  var highSumpPin = 0;
                  var lowSumpPin = 0;
                  var levelSensor = 0;
                  var pressureSensor = 0;
                  var waterMeter = 0;
                  if(pump['rfNo'] == oroPumpPlus['referenceNumber'].toString()){
                    masterSlave += '${masterSlave.isNotEmpty ? ',' : ''}${2}';
                    pumpCount += 1;
                    if(pump['TopTankHigh'].isNotEmpty){
                      highTankPin = pump['TopTankHigh']['input'] == '-' ? 0 : int.parse(pump['TopTankHigh']['input'].split('-')[1]);
                      tankPin += 1;
                    }
                    if(pump['TopTankLow'].isNotEmpty){
                      lowTankPin = pump['TopTankLow']['input'] == '-' ? 0 : int.parse(pump['TopTankLow']['input'].split('-')[1]);
                      tankPin += 1;
                    }
                    if(pump['SumpTankHigh'].isNotEmpty){
                      highSumpPin = pump['SumpTankHigh']['input'] == '-' ? 0 : int.parse(pump['SumpTankHigh']['input'].split('-')[1]);
                      sumpPin += 1;
                    }
                    if(pump['SumpTankLow'].isNotEmpty){
                      lowSumpPin = pump['SumpTankLow']['input'] == '-' ? 0 : int.parse(pump['SumpTankLow']['input'].split('-')[1]);
                      sumpPin += 1;
                    }
                    if(pump['levelSensor'].isNotEmpty){
                      levelSensor = 1;
                    }
                    if(pump['pressureSensor'].isNotEmpty){
                      pressureSensor = 1;
                    }
                    if(pump['waterMeter'].isNotEmpty){
                      waterMeter = 1;
                    }
                    tankPayLoad += '$sumpPin,$lowSumpPin,$highSumpPin,$tankPin,$lowTankPin,$highTankPin,$levelSensor,$waterMeter,$pressureSensor,';
                  }
                }
              }
            }
            if(pumpCount != 0){
              var actualPumpPayload = convert.jsonEncode({"sentSms":"pumpconfig,$pumpCount,${oroPumpPlus['referenceNumber']},$masterSlave"});
              var gemPumpPayload = convert.jsonEncode({
                '5900' : [
                  {
                    '5901' : '${oroPumpPlus['serialNumber']}+'
                        '${oroPumpPlus['referenceNumber']}+'
                        '${oroPumpPlus['deviceId']}+'
                        '${oroPumpPlus['interfaceTypeId']}+'
                        '${convert.jsonEncode({'700' : actualPumpPayload})}'
                  }
                ]
              });
              newPayload['${oroPumpPlus['deviceId']}-pumpconfig'] = {
                'payload' : [1,2].contains(configPvd.categoryId) ? gemPumpPayload : actualPumpPayload,
                'code' : '400',
                'message' : '',
                'macAddress' : [1,2].contains(configPvd.categoryId) ? widget.imeiNo : '${oroPumpPlus['deviceId']}',
                'checkingCode' : '700',
              };
              var actualTankPayload = convert.jsonEncode({"sentSms":"tankconfig,$tankPayLoad"});
              var gemTankPayload = convert.jsonEncode({
                '5900' : [
                  {
                    '5901' : '${oroPumpPlus['serialNumber']}+'
                        '${oroPumpPlus['referenceNumber']}+'
                        '${oroPumpPlus['deviceId']}+'
                        '${oroPumpPlus['interfaceTypeId']}+'
                        '${convert.jsonEncode({'800' : actualTankPayload})}'
                  }
                ]
              });
              newPayload['${oroPumpPlus['deviceId']}-tankconfig'] = {
                'payload' : [1,2].contains(configPvd.categoryId) ? gemTankPayload : actualPumpPayload,
                'code' : '400',
                'message' : '',
                'macAddress' : [1,2].contains(configPvd.categoryId) ? widget.imeiNo : '${oroPumpPlus['deviceId']}',
                'checkingCode' : '800',
              };
            }
          }
        }catch(e){
          if (kDebugMode) {
            print('Error on OroPumpPlus Payload Conversion Failed => \n'
                ' ${e.toString()}\n'
                '------------------------------------------------------------------------------------------');
            status = HttpMqttStatus.payloadConversionFailed;
          }
        }

      }
    }
    //Todo Sending To Mqtt
    if(status == HttpMqttStatus.success){
      keyLoop : for(var npKey in newPayload.keys){
        bool individualPayloadStatus = false;
        try{
          if (kDebugMode) {
            print('Sending to :: ${'AppToFirmware/${newPayload[npKey]['macAddress']}'}');
          }
          print('newPayload => ${newPayload}');
          bool skipPayload = false;
          if(payloadFromStart == false){
            if(configPvd.serverData['configMaker']['hardware'][npKey] != null){
              if(configPvd.serverData['configMaker']['hardware'][npKey]['code'] == '200'){
                skipPayload = true;
              }
            }
          }
          if(!skipPayload){
            MQTTManager().publish(newPayload[npKey]['payload'],'AppToFirmware/${newPayload[npKey]['macAddress']}');
            delayLoop : for(var i = 0;i < 60;i++){
              print('waiting response for ${newPayload[npKey]['macAddress']} sec :: ${i+1}');
              await Future.delayed(Duration(seconds: 1));
              print('reply : ${payloadProvider.messageFromHw}');
              print('npKey : $npKey');
              if(npKey.contains('-')){
                print('1111111111111111111111 ${newPayload[npKey]['checkingCode']}--- ${npKey.split('-')[0]}');
                if(payloadProvider.messageFromHw.containsKey('cM')
                    && payloadProvider.messageFromHw.containsKey('cC')){
                  if(payloadProvider.messageFromHw['cM'].contains(newPayload[npKey]['checkingCode'])
                      && payloadProvider.messageFromHw['cC'].contains(npKey.split('-')[0])){
                    individualPayloadStatus = true;
                    break delayLoop;
                  }
                }
              }else{
                print('222222222222222222222');
                if(payloadProvider.messageFromHw.containsKey('Code') && payloadProvider.messageFromHw.containsKey('PayloadCode')){
                  if(payloadProvider.messageFromHw['Code'] == '200' && payloadProvider.messageFromHw['PayloadCode'] == '200'){
                    individualPayloadStatus = true;
                    break delayLoop;
                  }
                }
              }
            }
            if(individualPayloadStatus == false){
              status = HttpMqttStatus.mqttFailed;
            }
          }
        }catch(e,stackTrace){
          status = HttpMqttStatus.mqttFailed;
          if (kDebugMode) {
            print('Error on Mqtt => \n'
                ' ${e.toString()}\n'
                '------------------------------------------------------------------------------------------');
          }
        }
        if(status == HttpMqttStatus.mqttFailed){
          setState(() {
            configPvd.wantToSendData = 3;
          });
          break keyLoop;
        }
      }
      setState(() {
        configPvd.serverData['configMaker']['hardware'] = newPayload;
      });
    }
    try{
      //Todo http
      configPvd.sendData();
      configPvd.configFinish();
      var body = {
        "userId" : widget.customerID,
        "createUser" : widget.userId,
        "controllerId" : widget.controllerId,
        'controllerReadStatus' : status == HttpMqttStatus.success ? '1' : '0',
        "productLimit" : {
          'newSnoList' : configPvd.newSnoList,
          'oWeather' : configPvd.oWeather,
          'oRoWeatherForStation' : configPvd.oRoWeatherForStation,
          'totalTempSensor' : configPvd.totalTempSensor,
          'connTempSensor' : configPvd.connTempSensor,
          'totalSoilTempSensor' : configPvd.totalSoilTempSensor,
          'connSoilTempSensor' : configPvd.connSoilTempSensor,
          'totalHumidity' : configPvd.totalHumidity,
          'connHumidity' : configPvd.connHumidity,
          'totalCo2' : configPvd.totalCo2,
          'connCo2' : configPvd.connCo2,
          'totalLux' : configPvd.totalLux,
          'connLux' : configPvd.connLux,
          'totalLdr' : configPvd.totalLdr,
          'connLdr' : configPvd.connLdr,
          'totalWindSpeed' : configPvd.totalWindSpeed,
          'connWindSpeed' : configPvd.connWindSpeed,
          'totalWindDirection' : configPvd.totalWindDirection,
          'connWindDirection' : configPvd.connWindDirection,
          'totalRainGauge' : configPvd.totalRainGauge,
          'connRainGauge' : configPvd.connRainGauge,
          'totalLeafWetness' : configPvd.totalLeafWetness,
          'connLeafWetness' : configPvd.connLeafWetness,
          'totalWaterSource' : configPvd.totalWaterSource,
          'totalWaterMeter' : configPvd.totalWaterMeter,
          'totalPressureSwitch' : configPvd.totalPressureSwitch,
          'totalDiffPressureSensor' : configPvd.totalDiffPressureSensor,
          'totalFloat' : configPvd.totalFloat,
          'totalSourcePump' : configPvd.totalSourcePump,
          'totalIrrigationPump' : configPvd.totalIrrigationPump,
          'totalInjector' : configPvd.totalInjector,
          'totalDosingMeter' : configPvd.totalDosingMeter,
          'totalBooster' : configPvd.totalBooster,
          'totalCentralDosing' : configPvd.totalCentralDosing,
          'totalFilter' : configPvd.totalFilter,
          'total_D_s_valve' : configPvd.total_D_s_valve,
          'total_p_sensor' : configPvd.total_p_sensor,
          'totalCentralFiltration' : configPvd.totalCentralFiltration,
          'totalValve' : configPvd.totalValve,
          'totalMainValve' : configPvd.totalMainValve,
          'totalIrrigationLine' : configPvd.totalIrrigationLine,
          'totalLocalFiltration' : configPvd.totalLocalFiltration,
          'totalLocalDosing' : configPvd.totalLocalDosing,
          'totalRTU' : configPvd.totalRTU,
          'totalRtuPlus' : configPvd.totalRtuPlus,
          'totalOroSwitch' : configPvd.totalOroSwitch,
          'totalOroSense' : configPvd.totalOroSense,
          'totalOroSmartRTU' : configPvd.totalOroSmartRTU,
          'totalOroSmartRtuPlus' : configPvd.totalOroSmartRtuPlus,
          'totalOroLevel' : configPvd.totalOroLevel,
          'totalOroPump' : configPvd.totalOroPump,
          'totalOroExtend' : configPvd.totalOroExtend,
          'i_o_types' : configPvd.i_o_types,
          'totalAnalogSensor' : configPvd.totalAnalogSensor,
          'totalCommonPressureSensor' : configPvd.totalCommonPressureSensor,
          'totalCommonPressureSwitch' : configPvd.totalCommonPressureSwitch,
          'totalTankFloat' : configPvd.totalTankFloat,
          'totalManualButton' : configPvd.totalManualButton,
          'totalContact' : configPvd.totalContact,
          'totalAgitator' : configPvd.totalAgitator,
          'totalSelector' : configPvd.totalSelector,
          'totalPhSensor' : configPvd.totalPhSensor,
          'totalEcSensor' : configPvd.totalEcSensor,
          'totalMoistureSensor' : configPvd.totalMoistureSensor,
          'totalLevelSensor' : configPvd.totalLevelSensor,
          'totalFan' : configPvd.totalFan,
          'totalFogger' : configPvd.totalFogger,
          'oRtu' : configPvd.oRtu,
          'oRtuPlus' : configPvd.oRtuPlus,
          'oSrtu' : configPvd.oSrtu,
          'oSrtuPlus' : configPvd.oSrtuPlus,
          'oSwitch' : configPvd.oSwitch,
          'oSense' : configPvd.oSense,
          'oLevel' : configPvd.oLevel,
          'oPump' : configPvd.oPump,
          'oPumpPlus' : configPvd.oPumpPlus,
          'oExtend' : configPvd.oExtend,
          'rtuForLine' : configPvd.rtuForLine,
          'rtuPlusForLine' : configPvd.rtuPlusForLine,
          'OroExtendForLine' : configPvd.OroExtendForLine,
          'switchForLine' : configPvd.switchForLine,
          'OroSmartRtuForLine' : configPvd.OroSmartRtuForLine,
          'OroSmartRtuPlusForLine' : configPvd.OroSmartRtuPlusForLine,
          'OroSenseForLine' : configPvd.OroSenseForLine,
          'OroLevelForLine' : configPvd.OroLevelForLine,
          'waterSource' : configPvd.waterSource,
          'weatherStation' : configPvd.weatherStation,
          'central_dosing_site_list' : configPvd.central_dosing_site_list,
          'central_filtration_site_list' : configPvd.central_filtration_site_list,
          'irrigation_pump_list' : configPvd.irrigation_pump_list,
          'water_source_list' : configPvd.water_source_list,
          'I_O_autoIncrement' : configPvd.I_O_autoIncrement,
          'oldData' : configPvd.serverData['productLimit'],
        },
        "sourcePump" : configPvd.sourcePumpUpdated,
        "irrigationPump" : configPvd.irrigationPumpUpdated,
        "centralFertilizer" : configPvd.centralDosingUpdated,
        "centralFilter" : configPvd.centralFiltrationUpdated,
        "irrigationLine" : configPvd.irrigationLines,
        "localFertilizer" : configPvd.localDosingUpdated,
        "localFilter" : configPvd.localFiltrationUpdated,
        "weatherStation" : configPvd.weatherStation,
        "mappingOfOutput" : {},
        "mappingOfInput" : {},
        'hardware' : ![3,4].contains(configPvd.categoryId) ? configPvd.sendData() : {},
        'names' : configPvd.configFinish(),
        'isNewConfig' : configPvd.isNew == true ? '1' : '0',
      };
      HttpService service = HttpService();
      var response = await service.postRequest('createUserConfigMaker', body);
      var jsonData = convert.jsonDecode(response.body);
      if(jsonData['code']  == 200){
        if(status == HttpMqttStatus.success){
          configPvd.editWantToSendData(2);
        }else if(status == HttpMqttStatus.payloadConversionFailed){
          configPvd.editWantToSendData(5);
        } else{
          configPvd.editWantToSendData(4);
        }
      }else{
        configPvd.editWantToSendData(3);
      }
    }catch(e,stackTrace){
      print('code error may be server : ${e.toString()}');
      print('code error stackTrace : $stackTrace');
      configPvd.editWantToSendData(3);
    }
    // CreateJsonFile store = CreateJsonFile();
    // store.writeDataInJsonFile('configFile', configPvd.sendData());
  }
}
