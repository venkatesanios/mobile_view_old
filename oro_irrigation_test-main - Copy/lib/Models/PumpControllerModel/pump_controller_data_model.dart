class PumpControllerData {
  List<IndividualPumpData> pumps;
  dynamic voltage;
  dynamic current;
  dynamic signalStrength;
  dynamic batteryStrength;
  String numberOfPumps;

  PumpControllerData({required this.pumps, required this.voltage, required this.current, required this.batteryStrength, required this.signalStrength, required this.numberOfPumps});

  factory PumpControllerData.fromJson(Map<String, dynamic> json, String key) {
    List<dynamic> pumpsJson = json[key] ?? [];
    dynamic lastElement = {};
    if(pumpsJson.isNotEmpty) {
      lastElement = pumpsJson.last;
      pumpsJson.removeLast();
    }

    print(lastElement);
    return PumpControllerData(
      pumps: List<IndividualPumpData>.from(pumpsJson.map((x) => IndividualPumpData.fromJson(x))),
      voltage: lastElement['V'] ?? "",
      current: lastElement['C'] ?? "",
      signalStrength: lastElement['SS'] ?? "",
      batteryStrength: lastElement['B'] ?? "",
      numberOfPumps: lastElement['NP'] ?? "1",
    );
  }
}

class IndividualPumpData {
  int status;
  int reason;
  String waterMeter;
  dynamic pressure;
  String level;
  String float;
  String onDelayTimer;
  String onDelayComplete;
  String onDelayLeft;

  IndividualPumpData({
    required this.status,
    required this.reason,
    required this.waterMeter,
    required this.pressure,
    required this.level,
    required this.float,
    required this.onDelayTimer,
    required this.onDelayComplete,
    required this.onDelayLeft
  });

  factory IndividualPumpData.fromJson(Map<String, dynamic> json) {
    return IndividualPumpData(
        status: json["ST"] ?? 0,
        reason: json["RN"],
        waterMeter: json["WM"],
        pressure: json["PR"],
        level: json["LV"],
        float: json["FT"],
        onDelayTimer: json["OD"],
        onDelayComplete: json["ODC"],
        onDelayLeft: json["ODL"]
    );
  }
}