class NodeModel {
  final dynamic controllerId, serialNumber;
  final String modelName;
  final String categoryName;
  final dynamic deviceId;
  final String deviceName;
  final dynamic referenceNumber;
  dynamic slrVolt;
  dynamic batVolt;
  List<RelayStatus> rlyStatus;
  List<Sensor> sensor;
  dynamic status;

  NodeModel({
    required this.controllerId,
    required this.serialNumber,
    required this.modelName,
    required this.categoryName,
    required this.deviceId,
    required this.deviceName,
    required this.referenceNumber,
    required this.slrVolt,
    required this.batVolt,
    required this.rlyStatus,
    required this.sensor,
    required this.status,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    var rlyStatusList = json['RlyStatus'] as List;
    List<RelayStatus> rlyStatus = rlyStatusList.map((rlyStatus) => RelayStatus.fromJson(rlyStatus)).toList();

    var sensorList = json['Sensor'] as List;
    List<Sensor> sensor = sensorList.map((sensor) => Sensor.fromJson(sensor)).toList();
    return NodeModel(
      controllerId: json['controllerId'],
      serialNumber: json['serialNumber'],
      modelName: json['modelName'],
      categoryName: json['categoryName'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      referenceNumber: json['referenceNumber'],
      slrVolt: json['SVolt'] ?? 0.0,
      batVolt: json['BatVolt'] ?? 0.0,
      rlyStatus: rlyStatus,
      sensor: sensor,
      status: json['Status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "controllerId": controllerId,
      "serialNumber": serialNumber,
      "modelName": modelName,
      "categoryName": categoryName,
      "deviceId": deviceId,
      "deviceName": deviceName,
      "referenceNumber": referenceNumber,
      "slrVolt": slrVolt,
      "batVolt": batVolt,
      "rlyStatus": rlyStatus.map((e) => e.toJson()).toList(),
      "sensor": sensor.map((e) => e.toJson()).toList(),
      "status": status,
    };
  }

  NodeModel updateStatus(dynamic newStatus) {
    return NodeModel(
      controllerId: this.controllerId,
      serialNumber: this.serialNumber,
      modelName: this.modelName,
      categoryName: this.categoryName,
      deviceId: this.deviceId,
      deviceName: this.deviceName,
      referenceNumber: this.referenceNumber,
      slrVolt: this.slrVolt,
      batVolt: this.batVolt,
      rlyStatus: this.rlyStatus,
      sensor: this.sensor,
      status: newStatus,
    );
  }
}

class Sensor {
  final String? Name;
  final String? Value;

  Sensor({
    required this.Name,
    required this.Value,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      Name: json['Name'],
      Value: json['Value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": Name,
      "value": Value
    };
  }
}

class RelayStatus {
  final String? name;
  final dynamic rlyNo;
  final dynamic status;

  RelayStatus({
    required this.name,
    required this.rlyNo,
    required this.status,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      name: json['Name'],
      rlyNo: json['RlyNo'],
      status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "rlyNo": rlyNo,
      "status": status
    };
  }
}