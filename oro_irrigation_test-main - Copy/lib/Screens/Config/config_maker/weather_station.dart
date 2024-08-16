import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/Screens/Customer/IrrigationProgram/preview_screen.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme.dart';
import '../../../state_management/config_maker_provider.dart';


class WeatherStationConfig extends StatefulWidget {
  const WeatherStationConfig({super.key});

  @override
  State<WeatherStationConfig> createState() => _WeatherStationConfigState();
}

class _WeatherStationConfigState extends State<WeatherStationConfig> {
  @override

  Map<String,dynamic> returnGridSize(width,height){
    int count = 0;
    double tSize= 0;
    double oWeatherHeight = 0;
    double iSize = 0;
    if(width > 1100){
      count = 11;
      tSize = 12;
      oWeatherHeight = 200;
      iSize = 45;
    }else if(width > 850){
      count = 8;
      tSize = 12;
      oWeatherHeight = 320;
      iSize = 55;
    }else if(width > 720){
      count = 7;
      tSize = 12;
      oWeatherHeight = 320;
      iSize = 55;
    }else if(width > 620){
      count = 6;
      tSize = 12;
      oWeatherHeight = 320;
      iSize = 55;
    }else if(width > 300){
      count = 5;
      tSize = 10;
      oWeatherHeight = 320;
      iSize = 35;
    }else if(width > 100){
      count = 3;
      tSize = 10;
      oWeatherHeight = 400;
      iSize = 35;
    }
    return {
      'oroWeatherHeight' : oWeatherHeight,
      'count' : count,
      'imageSize' : iSize,
      'textSize' : tSize
    };
  }

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        padding: const EdgeInsets.all(10),
        color: const Color(0xFFF3F3F3),
        child: Column(
          children: [
            const SizedBox(height: 5,),
            Row(
              children: [
                InkWell(
                  onTap: (){
                    var add = false;
                    for(var key in configPvd.weatherStation.keys){
                      if(configPvd.weatherStation[key]['apply'] == false){
                        add = true;
                      }
                    }
                    if(add == false){
                      showDialog(
                          context: context,
                          builder: (context){
                            return showingMessage('Oops!', 'The weather station limit is achieved!..', context);
                          }
                      );
                    }else{
                      configPvd.weatherStationFuntionality(['add']);
                    }
                  },
                  child: Container(
                    width: 180,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: myTheme.primaryColor
                    ),
                    child: Center(
                      child: Text('Add ORO Weather(${configPvd.weatherStation.keys.where((element) => configPvd.weatherStation[element]['apply'] == false).toList().length})',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w100),),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(var key in configPvd.weatherStation.keys)
                        if(configPvd.weatherStation[key]['apply'] == true)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryColorDark
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                      child: Text('ORO WEATHER ${configPvd.weatherStation.keys.toList().indexOf(key) + 1}',style: TextStyle(color: Colors.white),)
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: IconButton(
                                          onPressed: (){
                                            configPvd.weatherStationFuntionality(['delete',key]);
                                          },
                                          icon: const Icon(Icons.delete,color: Colors.orange,),
                                        )
                                    )
                                  ],
                                ),
                              ),
                              Wrap(
                                children: [
                                  for(var sensor in configPvd.weatherStation[key].keys)
                                    if(sensor != 'apply')
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: customBoxShadow
                                        ),
                                        width: 250,
                                        child: CheckboxListTile(
                                          title: Text(sensor),
                                          value: configPvd.weatherStation[key][sensor]['apply'],
                                          onChanged: (bool? value) {
                                            configPvd.weatherStationFuntionality(['sensorUpdate',key,sensor]);
                                          },
                                        ),
                                      )
                                ],
                              ),
                            ],
                          ),
                      const SizedBox(height: 100,)
                    ],
                  ),
                )
            )

          ],
        ),
      );
    },);
  }
  int gridCount(BoxConstraints constraints){
    if(constraints.maxWidth > 1000){
      return 8;
    }else if(constraints.maxWidth > 800){
      return 7;
    }else if(constraints.maxWidth > 600){
      return 5;
    }else if(constraints.maxWidth > 400){
      return 4;
    }else{
      return 3;
    }
  }
  List<dynamic> weatherFeatures(int index){
    switch (index){
      case 0:{
        return ['Temperature','assets/images/temperature.png'];
      }
      case 1:{
        return ['Humidity','assets/images/humidity.png'];
      }
      case 2:{
        return ['Wind Speed','assets/images/windSpeed.png'];
      }
      case 3:{
        return ['Rain','assets/images/windDirection.png'];
      }
      case 4:{
        return ['Atm.Pressure','assets/images/moisture.png'];
      }
      case 5:{
        return ['UV-Radiation','assets/images/rainGauge.png'];
      }
      case 6:{
        return ['Alert','assets/images/soilTemperature.png'];
      }
      case 7:{
        return ['Daily Forecast','assets/images/lux.png'];
      }
      case 8:{
        return ['Sunset','assets/images/co2.png'];
      }
      case 9:{
        return ['W-Prediction','assets/images/ldrSensor.png'];
      }
      case 10:{
        return ['W-Prediction','assets/images/leafWetness.png'];
      }
      default:{
        return ['nothing'];
      }
    }
  }
}