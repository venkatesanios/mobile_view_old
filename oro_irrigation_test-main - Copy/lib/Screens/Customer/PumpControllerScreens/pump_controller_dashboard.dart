import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../Models/PumpControllerModel/pump_controller_data_model.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';
class PumpControllerDashboard extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int selectedSite;
  final int selectedMaster;
  final String deviceId;
  const PumpControllerDashboard({super.key, required this.userId, required this.deviceId, required this.controllerId, required this.selectedSite, required this.selectedMaster});

  @override
  State<PumpControllerDashboard> createState() => _PumpControllerDashboardState();
}

class _PumpControllerDashboardState extends State<PumpControllerDashboard> with TickerProviderStateMixin{
  late MqttPayloadProvider mqttPayloadProvider;
  // late PumpControllerProvider pumpControllerProvider;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    // pumpControllerProvider = Provider.of<PumpControllerProvider>(context, listen: false);
    // dataModel = PumpControllerData.fromJson({});
    // pumpControllerProvider.getLive(mqttPayloadProvider.pumpControllerPayload);
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
    getLive();
    getPumpControllerData();
    _controller.addListener(() {setState(() {});});
    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  Future<void> getPumpControllerData() async {
    var data = {"userId": widget.userId};
    // print("invoked");
    try {
      final getPumpController = await HttpService().postRequest("getCustomerDashboard", data);
      final response = jsonDecode(getPumpController.body);
      // print(response['data'][3]['master'][0]['liveMessage']);
      mqttPayloadProvider.pumpControllerData = PumpControllerData.fromJson(response['data'][widget.selectedSite]['master'][widget.selectedMaster], "liveMessage");
      print(mqttPayloadProvider.pumpControllerData?.current);
    } catch(e) {
      print(e);
    }
  }

  Future<void> getLive() async{
    MQTTManager().publish(jsonEncode({
      "sentSms": "#live"
    }),"AppToFirmware/${widget.deviceId}");
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    // print(mqttPayloadProvider.pumpControllerPayload);
    // pumpControllerProvider = Provider.of<PumpControllerProvider>(context, listen: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // print(mqttPayloadProvider.dataModel?.pumps.map((e) => e.status));
    return Scaffold(
      appBar: AppBar(title: Text("Pump controller", style: TextStyle(color: Colors.white)), centerTitle: true,),
      body: (mqttPayloadProvider.dataModel != null && mqttPayloadProvider.dataModel!.pumps.isNotEmpty) ? Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                surfaceTintColor: Theme.of(context).primaryColor.withOpacity(0.5),
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                elevation: 10,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildRow(
                          context: context,
                          title: "Battery percentage",
                          icon: Icons.battery_0_bar,
                          value: "${mqttPayloadProvider.pumpControllerData?.batteryStrength.toString() ?? "0"}%"
                      ),
                      buildRow(
                          context: context,
                          title: "Signal strength",
                          icon: Icons.signal_cellular_alt_2_bar_sharp,
                          value: "${mqttPayloadProvider.pumpControllerData?.signalStrength.toString() ?? "0"}%"
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for(var index = 0; index < 3; index++)
                    buildContainer(
                      title: ["R", "Y", "B"][index],
                      value: mqttPayloadProvider.dataModel!.voltage.split(',')[index],
                      color1: [
                        const Color(0xfffcaaa7),
                        const Color(0xffffe29a),
                        const Color(0xffa1c1fa)][index],
                      color2: [
                        const Color(0xffff9b98),
                        const Color(0xfffae09f),
                        const Color(0xffa2cfff)][index],
                    )
                ],
              ),
              const SizedBox(height: 5,),
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for(var index = 0; index < int.parse(mqttPayloadProvider.dataModel!.numberOfPumps); index++)
                      // Text("${mqttPayloadProvider.dataModel!.current.toString()}")
                        buildPumpDetails(
                          index: index,
                          mode: mqttPayloadProvider.dataModel!.pumps[index].status,
                          currentValue: mqttPayloadProvider.dataModel!.current.split(',')[index],
                          onDelayTimer: mqttPayloadProvider.dataModel!.pumps[index].onDelayTimer,
                          onDelayLeft: mqttPayloadProvider.dataModel!.pumps[index].onDelayLeft,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ) : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FilledButton(
        onPressed: (){
          getLive();
          print(mqttPayloadProvider.dataModel!.numberOfPumps);
        },
        child: const Text('Request live'),
      ),
    );
  }

  Row buildRow({required BuildContext context, required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white,),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$title  ",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPumpDetails({required int index, required int mode, required String currentValue, required String onDelayTimer, required String onDelayLeft}) {
    List<String> inputTimeParts = onDelayTimer.split(':');
    int inHours = int.parse(inputTimeParts[0]);
    int inMinutes = int.parse(inputTimeParts[1]);
    int inSeconds = int.parse(inputTimeParts[2]);

    List<String> timeComponents = onDelayLeft.split(':');
    int hours = int.parse(timeComponents[0]);
    int minutes = int.parse(timeComponents[1]);
    int seconds = int.parse(timeComponents[2]);

    Duration inDuration = Duration(hours: inHours, minutes: inMinutes, seconds: inSeconds);
    Duration completedDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);

    final toLeftDuration = (inDuration - completedDuration).toString().substring(0,7);
    final progressValue = completedDuration.inMilliseconds / inDuration.inMilliseconds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
      decoration: BoxDecoration(
          boxShadow: neumorphicButtonShadow,
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Turned off due to rtc ${mqttPayloadProvider.pumpControllerData!.pumps[index].reason.toString()}", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 18),),
              Switch(
                value: mqttPayloadProvider.dataModel!.pumps[index].status == 1,
                onChanged: (newValue) async {
                  setState(() {
                    if (mqttPayloadProvider.dataModel!.pumps[index].status == 1) {
                      mqttPayloadProvider.dataModel!.pumps[index].status = -1;
                      MQTTManager().publish(
                          jsonEncode({"sentSms": "motor${index + 1}off"}),
                          "AppToFirmware/${widget.deviceId}"
                      );
                      var data = {
                        "userId": widget.userId,
                        "controllerId": widget.controllerId,
                        "data": {"sentSms": "motor${index + 1}off"},
                        "messageStatus": "Motor${index + 1} Off",
                        "createUser": widget.userId
                      };
                      HttpService().postRequest("createUserManualOperationInDashboard", data);
                      monitorStatusChange(context, index, 0);
                    } else {
                      mqttPayloadProvider.dataModel!.pumps[index].status = -2;
                      MQTTManager().publish(
                          jsonEncode({"sentSms": "motor${index + 1}on"}),
                          "AppToFirmware/${widget.deviceId}"
                      );
                      var data = {
                        "userId": widget.userId,
                        "controllerId": widget.controllerId,
                        "data": {"sentSms": "motor${index + 1}on"},
                        "messageStatus": "Motor${index + 1} On",
                        "createUser": widget.userId
                      };
                      HttpService().postRequest("createUserManualOperationInDashboard", data);
                      monitorStatusChange(context, index, 1);
                    }
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment: (mqttPayloadProvider.pumpControllerData!.pumps[index].level != "-" || mqttPayloadProvider.pumpControllerData!.pumps[index].waterMeter != "-") ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceAround,
            children: [
              if(mqttPayloadProvider.pumpControllerData!.pumps[index].level != "-")
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumn(title1: "Level in feet", value1: "${mqttPayloadProvider.pumpControllerData!.pumps[index].level.toString().split(',')[0]} feet"),
                    const SizedBox(height: 15,),
                    buildColumn(title1: "Level in %", value1: "80"),
                  ],
                ),
              getTypesOfPump(mode: mode, controller: _controller, animationValue: _animation.value),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildColumn(title1: "Current", value1: "${currentValue.substring(2)} A", alignStart: false),
                  const SizedBox(height: 15,),
                  if(mqttPayloadProvider.pumpControllerData!.pumps[index].waterMeter != "-")
                    buildColumn(title1: "Water meter", value1: "${mqttPayloadProvider.pumpControllerData!.pumps[index].waterMeter} L/hr", alignStart: false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            children: [
              if(mqttPayloadProvider.pumpControllerData!.pumps[index].pressure != "-")
                Expanded(child: buildColumn(title1: "Pressure in bar", value1: "${mqttPayloadProvider.pumpControllerData!.pumps[index].pressure} bar")),
              Expanded(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for(var i = 0; i < mqttPayloadProvider.pumpControllerData!.pumps[index].float.split(':').length; i++)
                        if( mqttPayloadProvider.pumpControllerData!.pumps[index].float.split(':')[i] != "-")
                          Row(
                            children: [
                              buildColumn(title1: "F${i+1}", value1: mqttPayloadProvider.pumpControllerData!.pumps[index].float.split(':')[0].toString() == "1" ? "High" : "Low"),
                              const SizedBox(width: 10,)
                            ],
                          ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> showAlertDialog(BuildContext dialogContext) async {
    await showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: const Text("Alert!"),
          content: Container(
            child: const Text('Wait for controller response!...'),
          ),
        );
      },
    );
  }

  void monitorStatusChange(BuildContext dialogContext, int index, int changeStatus) async {
    try {
      while ((mqttPayloadProvider.dataModel!.pumps[index].status == -1) || (mqttPayloadProvider.dataModel!.pumps[index].status == -2)) {
        await Future.delayed(Duration(seconds: 1));
      }
    } finally {
      Navigator.of(dialogContext).pop();
    }
  }

  Widget buildButton({required String label, required Color textColor, required void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // width: 60,
        // height: 60,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: neumorphicButtonShadow,
            color: const Color(0xffEAEAEA)
        ),
        child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                        offset: const Offset(2,2),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.3)
                    )
                  ]
              ),
            )
        ),
      ),
    );
  }

  Widget buildContainer({required String title, required String value, required Color color1, required Color color2}) {
    return Expanded(
      child: Card(
        // height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //         colors: [
        //           color1, color2
        //         ],
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter
        //     ),
        //     borderRadius: BorderRadius.circular(10),
        //     boxShadow: customBoxShadow
        // ),
        surfaceTintColor: color1,
        elevation: 20,
        color: color1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),),
              Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18),)
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildColumn({required String title1, required String value1, bool alignStart = true}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
    children: [
      Text(title1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),),
      Text(value1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),)
    ],
  );
}


List<BoxShadow> neumorphicButtonShadow = [
  BoxShadow(
      offset: const Offset(0, 20),
      blurRadius: 20,
      color: Colors.black.withOpacity(0.0405)
  ),
  BoxShadow(
      offset: const Offset(0, 15),
      blurRadius: 15,
      color: Colors.black.withOpacity(0.03)
  ),
  BoxShadow(
      offset: const Offset(0, 9),
      blurRadius: 18.2,
      color: Colors.black.withOpacity(0.0195)
  ),
  // BoxShadow(
  //     offset: const Offset(0, -20),
  //     blurRadius: 6.47,
  //     color: Colors.black.withOpacity(0.0195)
  // ),
];

Widget getTypesOfPump({required mode,required AnimationController controller,required double animationValue}){
  return AnimatedBuilder(
    animation: controller,
    builder: (BuildContext context, Widget? child) {
      return CustomPaint(
        painter: Pump(rotationAngle: [1,2].contains(mode)? animationValue : 0,mode: mode),
        size: const Size(100,80),
      );
    },
  );
}

class Pump extends CustomPainter {
  final double rotationAngle;
  final int mode;

  Pump({required this.rotationAngle,required this.mode});

  List<Color> pipeColor = const [Color(0xff166890), Color(0xff45C9FA), Color(0xff166890)];
  List<Color> bodyColor = const [Color(0xffC7BEBE), Colors.white, Color(0xffC7BEBE)];
  List<Color> headColorOn = const [Color(0xff097E54), Color(0xff10E196), Color(0xff097E54)];
  List<Color> headColorOff = const [Color(0xff540000), Color(0xffB90000), Color(0xff540000)];
  List<Color> headColorFault = const [Color(0xffF66E21), Color(0xffFFA06B), Color(0xffF66E21)];
  List<Color> headColorIdle = [Colors.grey, Colors.grey.shade300, Colors.grey];

  List<Color> getMotorColor(){
    if(mode == 1){
      return headColorOn;
    }else if(mode == 3){
      return headColorOff;
    }else if(mode == 2){
      return headColorFault;
    }else{
      return headColorIdle;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {

    Paint motorHead = Paint();
    Radius headRadius = const Radius.circular(5);
    motorHead.color = const Color(0xff097B52);
    motorHead.style = PaintingStyle.fill;
    motorHead.shader = getLinearShaderHor(getMotorColor(),Rect.fromCenter(center: const Offset(50,18), width: 35, height: 35));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: const Offset(50,20), width: 45, height: 40),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), motorHead);
    Paint line = Paint();
    line.color = Colors.white;
    line.strokeWidth = 1;
    line.style = PaintingStyle.fill;
    double startingPosition = 26;
    double lineGap = 8;
    for(var i = 0;i < 7;i++) {
      canvas.drawLine(Offset(startingPosition+(i*lineGap), 5), Offset(startingPosition+(i*lineGap), 35), line);
    }
    canvas.drawLine(const Offset(28, 5), const Offset(72, 5), line);
    canvas.drawLine(const Offset(28, 35), const Offset(72, 35), line);


    Paint neck = Paint();
    neck.shader = getLinearShaderHor(bodyColor,Rect.fromCenter(center: const Offset(50,45), width: 20, height: 10));
    neck.strokeWidth = 0.5;
    neck.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: const Offset(50,45 ), width: 20, height: 10), neck);

    Paint body = Paint();
    body.style = PaintingStyle.fill;
    body.shader = getLinearShaderHor(bodyColor,Rect.fromCenter(center: const Offset(50,64), width: 35, height: 28));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: const Offset(50,64), width: 35, height: 28),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), body);

    Paint joint = Paint();
    joint.shader = getLinearShaderVert(bodyColor,Rect.fromCenter(center: const Offset(30,64 ), width: 6, height: 15));
    joint.strokeWidth = 0.5;
    joint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: const Offset(30,64 ), width: 6, height: 15), joint);
    canvas.drawRect(Rect.fromCenter(center: const Offset(70,64 ), width: 6, height: 15), joint);

    Paint shoulder1 = Paint();
    shoulder1.shader = getLinearShaderVert(bodyColor,Rect.fromCenter(center: const Offset(24,64 ), width: 6, height: 20));
    shoulder1.strokeWidth = 0.5;
    shoulder1.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: const Offset(24,64 ), width: 6, height: 20), shoulder1);
    canvas.drawRect(Rect.fromCenter(center: const Offset(75,64 ), width: 6, height: 20), shoulder1);

    Paint shoulder2 = Paint();
    shoulder2.shader = getLinearShaderVert(pipeColor,Rect.fromCenter(center: const Offset(30,64), width: 6, height: 15));
    shoulder2.strokeWidth = 0.5;
    shoulder2.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: const Offset(20,64 ), width: 6, height: 20), shoulder2);
    canvas.drawRect(Rect.fromCenter(center: const Offset(80,64 ), width: 6, height: 20), shoulder2);

    Paint hand = Paint();
    hand.shader = getLinearShaderVert(pipeColor,Rect.fromCenter(center: const Offset(30,64), width: 6, height: 15));
    hand.strokeWidth = 0.5;
    hand.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: const Offset(10,64 ), width: 18, height: 15), hand);
    canvas.drawRect(Rect.fromCenter(center: const Offset(90,64 ), width: 18 , height: 15), hand);

    Paint paint = Paint()..color = Colors.blueGrey;
    double centerX = 50;
    double centerY = 65;
    double radius = 8;
    double angle = (2 * pi) / 4; // Angle between each rectangle
    double rectangleWidth = 8;
    double rectangleHeight = 10;

    for (int i = 0; i < 4; i++) {
      double x = centerX + radius * cos(i * angle + rotationAngle/2);
      double y = centerY + radius * sin(i * angle + rotationAngle/2);
      double rotation = i * angle - pi / 2 + rotationAngle; // Rotate rectangles to fit the circle

      canvas.save(); // Save canvas state before rotation
      canvas.translate(x, y); // Translate to the position
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-rectangleWidth / 2, -rectangleHeight / 2, rectangleWidth, rectangleHeight),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(80),
          topLeft: const Radius.circular(40),
          topRight: const Radius.circular(40),
        ),
        paint,
      );
      canvas.restore(); // Restore canvas state after rotation
    }
    Paint smallCircle = Paint();
    smallCircle.color = Colors.black;
    smallCircle.style = PaintingStyle.fill;

    // Draw a small circle at the center
    canvas.drawCircle(Offset(centerX, centerY), 4, smallCircle);
  }

  dynamic getLinearShaderVert(List<Color> colors,Rect rect){
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ).createShader(rect);
  }

  dynamic getLinearShaderHor(List<Color> colors,Rect rect){
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
    ).createShader(rect);
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
