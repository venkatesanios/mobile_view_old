import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';
import '../../../ListOfFertilizerInSet.dart';
import '../../../constants/http_service.dart';
import 'package:intl/intl.dart';

import '../../../state_management/overall_use.dart';

class SentAndReceived extends StatefulWidget {
  SentAndReceived({super.key});

  @override
  State<SentAndReceived> createState() => _SentAndReceivedState();
}

class _SentAndReceivedState extends State<SentAndReceived> {
  List<Message> messages = [];
  // List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));
  // DateTime startDate = DateTime.now();
  // DateTime endDate = DateTime.now();
  final ScrollController scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  late OverAllUse overAllPvd;
  @override
  void initState() {
    super.initState();
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    getUserSentAndReceivedMessageStatus();
  }

  Future<void> getUserSentAndReceivedMessageStatus() async {
    var data = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      final getPumpController = await HttpService().postRequest("getUserSentAndReceivedMessageStatus", data);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        setState(() {
          if (response['data'] is List) {
            messages = (response['data'] as List).map((e) => Message.fromJson(e)).toList();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(scrollController.position.maxScrollExtent+MediaQuery.of(context).size.height);
              }
            });
          } else {
            log('Data is not a List');
          }
        });
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("$e");
      log("stackTrace ==> $stackTrace");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text('Sent and Received', style: TextStyle(color: Theme.of(context).primaryColor),),
        centerTitle: true,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: const Color(0xffE9E9E9),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                boxShadow: customBoxShadow,
                color: Colors.white
            ),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.now(),
              calendarFormat: _calendarFormat,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle
                ),
                todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
                getUserSentAndReceivedMessageStatus();
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: messages.where((element) => element.date == selectedDate.toString().split(' ')[0]).toList().isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: messages.length,
              controller: scrollController,
              itemBuilder: (context, index) {
                final message = messages[index];
                return selectedDate.toString().split(' ')[0] == message.date
                    ? Column(
                  children: [
                    message.messageType == "SENT"
                        ? SentMessageBubble(
                      message: message.message,
                      time: message.time,
                      date: message.date,
                      sentUser: message.sentUser,
                      sentMobileNumber: message.sentMobileNumber,)
                        : ReceivedMessageBubble(message: message.message, time: message.time, date: message.date),
                  ],
                ) : Container();
              },
            ) : const Center(child: Text("User message not found", style: TextStyle(fontWeight: FontWeight.bold),)),
          ),
          // SizedBox(height: 50,)
        ],
      ),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     IconButton(
      //       onPressed: () {
      //         if (scrollController.hasClients) {
      //           scrollController.animateTo(
      //             scrollController.position.minScrollExtent,
      //             duration: Duration(milliseconds: 500), // Adjust duration as needed
      //             curve: Curves.easeOut, // Optional easing curve
      //           );
      //         }
      //       },
      //       icon: Icon(Icons.arrow_circle_up, color: Colors.green),
      //       style: ButtonStyle(
      //         backgroundColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1)),
      //       ),
      //     ),
      //     IconButton(
      //       onPressed: () {
      //         if (scrollController.hasClients) {
      //           scrollController.animateTo(
      //             scrollController.position.maxScrollExtent,
      //             duration: Duration(milliseconds: 500), // Adjust duration as needed
      //             curve: Curves.easeOut, // Optional easing curve
      //           );
      //         }
      //       },
      //       icon: Icon(Icons.arrow_circle_down, color: Colors.red),
      //       style: ButtonStyle(
      //         backgroundColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1)),
      //       ),
      //     ),
      //
      //   ],
      // ),
    );
  }
}

class SentMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final String date;
  final String sentUser;
  final String sentMobileNumber;

  const SentMessageBubble({super.key,
    required this.message,
    required this.time,
    required this.date,
    required this.sentUser,
    required this.sentMobileNumber
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width*0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          CustomPaint(
                            painter: ChatBubblePainter(true),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: sentUser, style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                                        TextSpan(text: "   $sentMobileNumber",
                                          style: const TextStyle(color: Colors.black87, fontSize: 12, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                  ),
                                  // Text(sentUser, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                  // Text(sentMobileNumber, style: const TextStyle(color: Colors.black, fontSize: 10)),
                                  const SizedBox(height: 8,),
                                  Text(message, style: const TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 0,
                          //   right: 8,
                          //   child: Text(sentMobileNumber, style: const TextStyle(color: Colors.black, fontSize: 14)),
                          // ),
                        ],
                      ),
                      const SizedBox(width: 10,),
                      Text(time, style: const TextStyle(color: Colors.black, fontSize: 10))
                    ],
                  ),
                ),
                const SizedBox(width: 5,),
                CircleAvatar(
                  backgroundColor: Color(0xffFDFDFD),
                  child: Text((sentUser.split(" ").first[0]+sentUser.split(" ").last[0]).toUpperCase(), style: TextStyle(color: Colors.purple),),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8,)
        ],
      ),
    );
  }
}

class ReceivedMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final String date;

  const ReceivedMessageBubble({super.key, required this.message, required this.time, required this.date});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width*0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xffE0FFF7),
                  child: Icon(Icons.computer, color: Theme.of(context).primaryColor,),
                ),
                const SizedBox(width: 5,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CustomPaint(
                            painter: ChatBubblePainter(false),
                            child: Container(
                              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                              padding: const EdgeInsets.only(right: 10,),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(sentUser, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                  // Text(sentMobileNumber, style: const TextStyle(color: Colors.black, fontSize: 10)),
                                  const SizedBox(height: 8,),
                                  Text(message, style: const TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 0,
                          //   right: 8,
                          //   child: Text(sentMobileNumber, style: const TextStyle(color: Colors.black, fontSize: 14)),
                          // ),
                        ],
                      ),
                      const SizedBox(width: 10,),
                      Text(time, style: const TextStyle(color: Colors.black, fontSize: 10))
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15,)
        ],
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final bool isMe;

  ChatBubblePainter(this.isMe);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe ? const Color(0xffFDFDFD) : const Color(0xffE0FFF7)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isMe) {
      // Right-aligned bubble
      path.moveTo(10, 0);
      path.lineTo(size.width + 10, 0);
      path.quadraticBezierTo(size.width, 10, size.width, 10);
      path.lineTo(size.width, size.height - 10);
      path.quadraticBezierTo(size.width, size.height, size.width - 10, size.height);
      path.lineTo(20, size.height);
      path.lineTo(10, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - 10);
      path.lineTo(0, 10);
      path.quadraticBezierTo(0, 0, 10, 0);
    } else {
      path.moveTo(size.width - 10, 0);
      path.lineTo(-10, 0);
      path.quadraticBezierTo(0, 10, 0, 10);
      path.lineTo(0, size.height - 10);
      path.quadraticBezierTo(0, size.height, 10, size.height);
      path.lineTo(size.width - 20, size.height);
      path.lineTo(size.width - 10, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - 10);
      path.lineTo(size.width, 10);
      path.quadraticBezierTo(size.width, 0, size.width - 10, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Message {
  final String messageType;
  final String date;
  final String time;
  final String message;
  final String sentUser;
  final String sentMobileNumber;

  Message({
    required this.messageType,
    required this.date,
    required this.time,
    required this.message,
    required this.sentUser,
    required this.sentMobileNumber
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageType: json['messageType'],
      date: json['date'],
      time: json['time'],
      message: json['message'],
      sentUser: json['sentUser'],
      sentMobileNumber: json['sentMobileNumber'],
    );
  }
}