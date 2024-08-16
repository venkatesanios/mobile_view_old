import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state_management/MqttPayloadProvider.dart';

class MyFunction {

  void clearMQTTPayload(context){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    payloadProvider.currentSchedule.clear();
    payloadProvider.PrsIn=[];
    payloadProvider.PrsOut=[];
    payloadProvider.programQueue.clear();
    payloadProvider.scheduledProgram.clear();
    payloadProvider.filtersCentral=[];
    payloadProvider.filtersLocal=[];
    payloadProvider.sourcePump=[];
    payloadProvider.irrigationPump=[];
    payloadProvider.fertilizerCentral=[];
    payloadProvider.fertilizerLocal=[];
    payloadProvider.waterMeter=[];
    payloadProvider.wifiStrength = 0;
    payloadProvider.alarmList = [];
    payloadProvider.payload2408 = [];
  }
}

enum GemProgramSSReasonCode {
  rs1(1, 'Running As Per Schedule'),
  rs2(2, 'Turned On Manually'),
  rs3(3, 'Started By Condition'),
  rs4(4, 'Turned Off Manually'),
  rs5(5, 'Program Turned Off'),
  rs6(6, 'Zone Turned Off'),
  rs7(7, 'Stopped By Condition'),
  rs8(8, 'Disabled By Condition'),
  rs9(9, 'StandAlone Program Started'),
  rs10(10, 'StandAlone Program Stopped'),
  rs11(11, 'StandAlone Program Stopped After Set Value'),
  rs12(12, 'StandAlone Manual Started'),
  rs13(13, 'StandAlone Manual Stopped'),
  rs14(14, 'StandAlone Manual Stopped After Set Value'),
  rs15(15, 'Started By Day Count Rtc'),
  rs16(16, 'Paused By User'),
  rs17(17, 'Manually Started Paused By User'),
  rs18(18, 'Program Deleted'),
  rs19(19, 'Program Ready'),
  rs20(20, 'Program Completed'),
  rs21(21, 'Resumed By User'),
  rs22(22, 'Paused By Condition'),
  rs23(23, 'Program Ready And Run By Condition'),
  rs24(24, 'Running As Per Schedule And Condition'),
  rs25(25, 'Started By Condition Paused By User'),
  rs26(26, 'Resumed By Condition'),
  rs27(27, 'Bypassed Start Condition Manually'),
  rs28(28, 'Bypassed Stop Condition Manually'),
  rs29(29, 'Continue Manually'),
  rs30(30, '-'),
  rs31(31, 'Program Completed'),
  rs32(32, 'Waiting For Condition'),
  rs33(33, 'Started By Condition and run as per Schedule'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;

  const GemProgramSSReasonCode(this.code, this.content);

  static GemProgramSSReasonCode fromCode(int code) {
    return GemProgramSSReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemProgramSSReasonCode.unknown,
    );
  }
}

enum GemLineSSReasonCode {
  lss1(1, 'The Line Paused Manually'),
  lss2(2, 'Scheduled Program paused by Standalone program'),
  lss3(3, 'The Line Paused By System Definition'),
  lss4(4, 'The Line Paused By Low Flow Alarm'),
  lss5(5, 'The Line Paused By High Flow Alarm'),
  lss6(6, 'The Line Paused By No Flow Alarm'),
  lss7(7, 'The Line Paused By Ec High'),
  lss8(8, 'The Line Paused By Ph Low'),
  lss9(9, 'The Line Paused By Ph High'),
  lss10(10, 'The Line Paused By Pressure Low'),
  lss11(11, 'The Line Paused By Pressure High'),
  lss12(12, 'The Line Paused By No Power Supply'),
  lss13(13, 'The Line Paused By No Communication'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;

  const GemLineSSReasonCode(this.code, this.content);

  static GemLineSSReasonCode fromCode(int code) {
    return GemLineSSReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemLineSSReasonCode.unknown,
    );
  }
}

String convert24HourTo12Hour(String timeString) {
  if(timeString=='-'){
    return '-';
  }
  final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
  final formattedTime = DateFormat('hh:mm a').format(parsedTime);
  return formattedTime;
}

enum PumpReasonCode {
  reason1(1, 'Motor off due to sump empty'),
  reason2(2, 'Motor off due to upper tank full'),
  reason3(3, 'Motor off due to low voltage'),
  reason4(4, 'Motor off due to high voltage'),
  reason5(5, 'Motor off due to voltage SPP'),
  reason6(6, 'Motor off due to reverse phase'),
  reason7(7, 'Motor off due to starter trip'),
  reason8(8, 'Motor off due to dry run'),
  reason9(9, 'Motor off due to overload'),
  reason10(10, 'Motor off due to current SPP'),
  reason11(11, 'Motor off due to cyclic trip'),
  reason12(12, 'Motor off due to maximum run time'),
  reason13(13, 'Motor off due to sump empty'),
  reason14(14, 'Motor off due to upper tank full'),
  reason15(15, 'Motor off due to RTC 1'),
  reason16(16, 'Motor off due to RTC 2'),
  reason17(17, 'Motor off due to RTC 3'),
  reason18(18, 'Motor off due to RTC 4'),
  reason19(19, 'Motor off due to RTC 5'),
  reason20(20, 'Motor off due to RTC 6'),
  reason21(21, 'Motor off due to auto mobile key off'),

  reason22(22, 'Motor on due to cyclic time'),
  reason23(23, 'Motor on due to RTC 1'),
  reason24(24, 'Motor on due to RTC 2'),
  reason25(25, 'Motor on due to RTC 3'),
  reason26(26, 'Motor on due to RTC 4'),
  reason27(27, 'Motor on due to RTC 5'),
  reason28(28, 'Motor on due to RTC 6'),
  reason29(29, 'Motor on due to auto mobile key on'),
  reason30(30, 'Motor on due to Power off'),
  reason31(31, 'Motor on due to Power on'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;
  final String motorOff = "Motor off due to";
  final String motorOn = "Motor on due to";

  const PumpReasonCode(this.code, this.content);

  static PumpReasonCode fromCode(int code) {
    return PumpReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => PumpReasonCode.unknown,
    );
  }
}

String getImageForProduct(String product) {
  String baseImgPath = 'assets/images/';
  String value = product.substring(0, 2);
  switch (value) {
    case 'VL':
      return '${baseImgPath}dl_valve.png';
    case 'MV':
      return '${baseImgPath}dl_main_valve.png';
    case 'SP':
      return '${baseImgPath}dl_source_pump.png';
    case 'IP':
      return '${baseImgPath}dl_irrigation_pump.png';
    case 'AS':
      return '${baseImgPath}dl_analog_sensor.png';
    case 'LS':
      return '${baseImgPath}dl_level_sensor.png';
    case 'FB':
      return '${baseImgPath}dl_booster_pump.png';
    case 'Central Filter Site':
      return '${baseImgPath}dl_central_filtration_site.png';
    case 'AG':
      return '${baseImgPath}dl_agitator.png';
    case 'Injector':
      return '${baseImgPath}dl_injector.png';
    case 'FL':
      return '${baseImgPath}dl_filter.png';
    case 'Downstream Valve':
      return '${baseImgPath}dl_downstream_valve.png';
    case 'Fan':
      return '${baseImgPath}dl_fan.png';
    case 'FB':
      return '${baseImgPath}dl_fogger.png';
    case 'SL':
      return '${baseImgPath}dl_selector.png';
    case 'Water Meter':
      return '${baseImgPath}dl_water_meter.png';
    case 'FM':
      return '${baseImgPath}dl_fertilizer_meter.png';
    case 'Co2 Sensor':
      return '${baseImgPath}dl_co2.png';
    case 'PSW':
      return '${baseImgPath}dl_pressure_switch.png';
    case 'LO':
      return '${baseImgPath}dl_pressure_sensor.png';
    case 'Differential Pressure Sensor':
      return '${baseImgPath}dl_differential_pressure_sensor.png';
    case 'EC':
      return '${baseImgPath}dl_ec_sensor.png';
    case 'PH':
      return '${baseImgPath}dl_ph_sensor.png';
    case 'Temperature':
      return '${baseImgPath}dl_temperature_sensor.png';
    case 'Soil Temperature Sensor':
      return '${baseImgPath}dl_soil_temperature_sensor.png';
    case 'Wind Direction Sensor':
      return '${baseImgPath}dl_wind_direction_sensor.png';
    case 'Wind Speed Sensor':
      return '${baseImgPath}dl_wind_speed_sensor.png';
    case 'LUX Sensor':
      return '${baseImgPath}dl_lux_sensor.png';
    case 'LDR Sensor':
      return '${baseImgPath}dl_ldr_sensor.png';
    case 'Humidity Sensor':
      return '${baseImgPath}dl_humidity_sensor.png';
    case 'Leaf Wetness Sensor':
      return '${baseImgPath}dl_leaf_wetness_sensor.png';
    case 'Rain Gauge Sensor':
      return '${baseImgPath}dl_rain_gauge_sensor.png';
    case 'Contact':
      return '${baseImgPath}dl_contact.png';
    case 'Weather Station':
      return '${baseImgPath}dl_weather_station.png';
    case 'Condition':
      return '${baseImgPath}dl_condition.png';
    case 'Valve Group':
      return '${baseImgPath}dl_valve_group.png';
    case 'Virtual Water Meter':
      return '${baseImgPath}dl_virtual_water_meter.png';
    case 'Program':
      return '${baseImgPath}dl_programs.png';
    case 'Radiation Set':
      return '${baseImgPath}dl_radiation_sets.png';
    case 'FC':
      return '${baseImgPath}dl_fertilization_sets.png';
    case 'Filter Set':
      return '${baseImgPath}dl_filter_sets.png';
    case 'SM':
      return '${baseImgPath}dl_moisture_sensor.png';
    case 'Float':
      return '${baseImgPath}dl_float.png';
    case 'Moisture Condition':
      return '${baseImgPath}dl_moisture_condition.png';
    case 'Tank Float':
      return '${baseImgPath}dl_tank_float.png';
    case 'Power Supply':
      return '${baseImgPath}dl_power_supply.png';
    case 'Level Condition':
      return '${baseImgPath}dl_level_condition.png';
    case 'Common Pressure Sensor':
      return '${baseImgPath}dl_common_pressure_sensor.png';
    case 'SW':
      return '${baseImgPath}dl_common_pressure_switch.png';
    default:
      return '${baseImgPath}dl_humidity_sensor.png';
  }
}