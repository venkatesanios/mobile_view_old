import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../../Models/Customer/log/irrigation_parameter_model.dart';

class ScrollingTable extends StatefulWidget {
  final String fixedColumn;
  final List<dynamic> fixedColumnData;
  final List<dynamic> generalColumn;
  final List<dynamic> generalColumnData;
  final List<dynamic> waterColumn;
  final List<dynamic> waterColumnData;
  final List<dynamic> prePostColumn;
  final List<dynamic> prePostColumnData;
  final List<dynamic> centralEcPhColumn;
  final List<dynamic> centralEcPhColumnData;
  final List<dynamic> centralChannel1Column;
  final List<dynamic> centralChannel1ColumnData;
  final List<dynamic> centralChannel2Column;
  final List<dynamic> centralChannel2ColumnData;
  final List<dynamic> centralChannel3Column;
  final List<dynamic> centralChannel3ColumnData;
  final List<dynamic> centralChannel4Column;
  final List<dynamic> centralChannel4ColumnData;
  final List<dynamic> centralChannel5Column;
  final List<dynamic> centralChannel5ColumnData;
  final List<dynamic> centralChannel6Column;
  final List<dynamic> centralChannel6ColumnData;
  final List<dynamic> centralChannel7Column;
  final List<dynamic> centralChannel7ColumnData;
  final List<dynamic> centralChannel8Column;
  final List<dynamic> centralChannel8ColumnData;
  final List<dynamic> localEcPhColumn;
  final List<dynamic> localEcPhColumnData;
  final List<dynamic> localChannel1Column;
  final List<dynamic> localChannel1ColumnData;
  final List<dynamic> localChannel2Column;
  final List<dynamic> localChannel2ColumnData;
  final List<dynamic> localChannel3Column;
  final List<dynamic> localChannel3ColumnData;
  final List<dynamic> localChannel4Column;
  final List<dynamic> localChannel4ColumnData;
  final List<dynamic> localChannel5Column;
  final List<dynamic> localChannel5ColumnData;
  final List<dynamic> localChannel6Column;
  final List<dynamic> localChannel6ColumnData;
  final List<dynamic> localChannel7Column;
  final List<dynamic> localChannel7ColumnData;
  final List<dynamic> localChannel8Column;
  final List<dynamic> localChannel8ColumnData;

  ScrollingTable({super.key,
    required this.fixedColumn,
    required this.fixedColumnData,
    required this.generalColumn,
    required this.generalColumnData,
    required this.waterColumn,
    required this.waterColumnData,
    required this.prePostColumn,
    required this.prePostColumnData,
    required this.centralEcPhColumn,
    required this.centralEcPhColumnData,
    required this.centralChannel1Column,
    required this.centralChannel1ColumnData,
    required this.centralChannel2Column,
    required this.centralChannel2ColumnData,
    required this.centralChannel3Column,
    required this.centralChannel3ColumnData,
    required this.centralChannel4Column,
    required this.centralChannel4ColumnData,
    required this.centralChannel5Column,
    required this.centralChannel5ColumnData,
    required this.centralChannel6Column,
    required this.centralChannel6ColumnData,
    required this.centralChannel7Column,
    required this.centralChannel7ColumnData,
    required this.centralChannel8Column,
    required this.centralChannel8ColumnData,
    required this.localEcPhColumn,
    required this.localEcPhColumnData,
    required this.localChannel1Column,
    required this.localChannel1ColumnData,
    required this.localChannel2Column,
    required this.localChannel2ColumnData,
    required this.localChannel3Column,
    required this.localChannel3ColumnData,
    required this.localChannel4Column,
    required this.localChannel4ColumnData,
    required this.localChannel5Column,
    required this.localChannel5ColumnData,
    required this.localChannel6Column,
    required this.localChannel6ColumnData,
    required this.localChannel7Column,
    required this.localChannel7ColumnData,
    required this.localChannel8Column,
    required this.localChannel8ColumnData});

  @override
  State<ScrollingTable> createState() => _ScrollingTableState();
}

class _ScrollingTableState extends State<ScrollingTable> {

  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;

  @override
  void initState() {
    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("widget.localChannel1ColumnData : ${widget.localChannel1ColumnData}");
    print("widget.centralChannel1ColumnData : ${widget.centralChannel1ColumnData}");
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))
        ),
        margin: const EdgeInsets.only(left: 5,right: 5),
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          var width = constraints.maxWidth;
          return Row(
            children: [
              Column(
                children: [
                  //Todo : first column
                  Container(
                    // color: Color(0xffF7F9FA),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff1C7C8A),
                            Color(0xff03464F),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                    ),
                    padding: const EdgeInsets.only(left: 8),
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text('${widget.fixedColumn}',style: TextStyle(color: Colors.white),),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _verticalScroll1,
                      child: Container(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                for(var i in widget.fixedColumnData)
                                  Container(
                                    color: Color(0xffDCF3DD),
                                    // color: Color(0xff2999A9),
                                    // decoration: BoxDecoration(
                                    //   gradient: LinearGradient(
                                    //     colors: [
                                    //       Color(0xff1C7C8A),
                                    //       Color(0xff03464F),
                                    //     ],
                                    //     begin: Alignment.centerLeft,
                                    //     end: Alignment.centerRight,
                                    //   )
                                    // ),
                                    padding: const EdgeInsets.only(left: 8),
                                    width: 100,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Text('${i}',style: TextStyle(color: Colors.black),),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    // color: Color(0xffF7F9FA),
                    color: Color(0xff03464F),
                    width: width-100,
                    height: 50,
                    child: SingleChildScrollView(
                      controller: _horizontalScroll1,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          getColumnDotLine(),
                          if(widget.generalColumn.isNotEmpty)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text('General',style: TextStyle(color: Colors.white),),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for(var i = 0;i < widget.generalColumn.length;i++)
                                      Container(
                                        // color: Color(0xffEAEAEA),
                                        color: Colors.orange.shade200,
                                        padding: const EdgeInsets.only(left: 8),
                                        width: widget.generalColumn[i] == 'Status' ? 150 : 100,
                                        height: 25,
                                        alignment: Alignment.centerLeft,
                                        child: Text('${widget.generalColumn[i]}',style: TextStyle(color: Colors.black),),
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          getColumnDotLine(),
                          if(widget.waterColumn.isNotEmpty)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text('Water',style: TextStyle(color: Colors.white),),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for(var i = 0;i < widget.waterColumn.length;i++)
                                      Container(
                                        color: Colors.orange.shade200,
                                        padding: const EdgeInsets.only(left: 8),
                                        width: 100,
                                        height: 25,
                                        alignment: Alignment.centerLeft,
                                        child: Text('${widget.waterColumn[i]}',style: TextStyle(color: Colors.black),),
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          getColumnDotLine(),
                          if(widget.prePostColumn.isNotEmpty)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text('Pre Post',style: TextStyle(color: Colors.white),),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for(var i = 0;i < widget.prePostColumn.length;i++)
                                      Container(
                                        color: Colors.orange.shade200,
                                        padding: const EdgeInsets.only(left: 8),
                                        width: 100,
                                        height: 25,
                                        alignment: Alignment.centerLeft,
                                        child: Text('${widget.prePostColumn[i]}',style: TextStyle(color: Colors.black),),
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          getColumnDotLine(),
                          if(widget.centralEcPhColumn.isNotEmpty)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text('<C-EC-PH>',style: TextStyle(color: Colors.white),),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for(var i = 0;i < widget.centralEcPhColumn.length;i++)
                                      Container(
                                        color: Colors.orange.shade200,
                                        padding: const EdgeInsets.only(left: 8),
                                        width: 100,
                                        height: 25,
                                        alignment: Alignment.centerLeft,
                                        child: Text('${widget.centralEcPhColumn[i]}',style: TextStyle(color: Colors.black),),
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          getColumnDotLine(),
                          if(widget.centralChannel1Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel1Column, channelNo: 1,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel2Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel2Column, channelNo: 2,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel3Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel3Column, channelNo: 3,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel4Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel4Column, channelNo: 4,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel5Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel5Column, channelNo: 5,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel6Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel6Column, channelNo: 6,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel7Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel7Column, channelNo: 7,central: true),
                          getColumnDotLine(),
                          if(widget.centralChannel8Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.centralChannel8Column, channelNo: 8,central: true),
                          getColumnDotLine(),
                          if(widget.localEcPhColumn.isNotEmpty)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text('<L-EC-PH>',style: TextStyle(color: Colors.white),),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for(var i = 0;i < widget.localEcPhColumn.length;i++)
                                      Container(
                                        color: Colors.orange.shade200,
                                        padding: const EdgeInsets.only(left: 8),
                                        width: 100,
                                        height: 25,
                                        alignment: Alignment.centerLeft,
                                        child: Text('${widget.localEcPhColumn[i]}',style: TextStyle(color: Colors.black),),
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          getColumnDotLine(),
                          if(widget.localChannel1Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel1Column, channelNo: 1,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel2Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel2Column, channelNo: 2,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel3Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel3Column, channelNo: 3,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel4Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel4Column, channelNo: 4,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel5Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel5Column, channelNo: 5,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel6Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel6Column, channelNo: 6,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel7Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel7Column, channelNo: 7,central: false),
                          getColumnDotLine(),
                          if(widget.localChannel8Column.isNotEmpty)
                            getChannelColumnWidget(columnList: widget.localChannel8Column, channelNo: 8,central: false),
                          getColumnDotLine(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: width-100,
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _horizontalScroll2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _horizontalScroll2,
                          child: Container(
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _verticalScroll2,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                controller: _verticalScroll2,
                                child: Row(
                                  children: [
                                    //TODO : GENERAL DATA
                                    Column(
                                      children: [
                                        for(var i in widget.generalColumnData)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 0,
                                                height: 50,
                                                child: CustomPaint(
                                                  painter: VerticalDotBorder(),
                                                  size: Size(10,50),
                                                ),
                                              ),
                                              for(var j = 0;j < i.length;j++)
                                                if(widget.generalColumn[j] == 'Status')
                                                  Container(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    width: 150,
                                                    height: 50,
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                        width: 150,
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          // color: getStatus(i[j])['color'],
                                                            borderRadius: BorderRadius.circular(20)
                                                        ),
                                                        child: Text('${getStatus(i[j])['status']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: getStatus(i[j])['textColor']),overflow: TextOverflow.ellipsis,)
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    width: 100,
                                                    height: 50,
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('${i[j] ?? '-'}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,),
                                                  ),
                                              SizedBox(
                                                width: 0,
                                                height: 50,
                                                child: CustomPaint(
                                                  painter: VerticalDotBorder(),
                                                  size: Size(0,50),
                                                ),
                                              )

                                            ],
                                          )
                                      ],
                                    ),
                                    //TODO : WATER DATA
                                    Column(
                                      children: [
                                        for(var i in widget.waterColumnData)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for(var j = 0;j < i.length;j++)
                                                Container(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  width: 100,
                                                  height: 50,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('${i[j] ?? '-'}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,),
                                                ),
                                              SizedBox(
                                                width: 0,
                                                height: 50,
                                                child: CustomPaint(
                                                  painter: VerticalDotBorder(),
                                                  size: Size(0,50),
                                                ),
                                              )

                                            ],
                                          )
                                      ],
                                    ),
                                    //TODO : PRE POST DATA
                                    Column(
                                      children: [
                                        for(var i in widget.prePostColumnData)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for(var j = 0;j < i.length;j++)
                                                Container(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  width: 100,
                                                  height: 50,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('${i[j] ?? '-'}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,),
                                                ),
                                              SizedBox(
                                                width: 0,
                                                height: 50,
                                                child: CustomPaint(
                                                  painter: VerticalDotBorder(),
                                                  size: Size(0,50),
                                                ),
                                              )

                                            ],
                                          )
                                      ],
                                    ),
                                    //TODO : CENTRAL ECPH DATA
                                    Column(
                                      children: [
                                        for(var i in widget.centralEcPhColumnData)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for(var j = 0;j < i.length;j++)
                                                Container(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  width: 100,
                                                  height: 50,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('${i[j] ?? '-'}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,),
                                                ),
                                              SizedBox(
                                                width: 0,
                                                height: 50,
                                                child: CustomPaint(
                                                  painter: VerticalDotBorder(),
                                                  size: Size(0,50),
                                                ),
                                              )

                                            ],
                                          )
                                      ],
                                    ),
                                    //TODO : CENTRAL CHANNEL
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel1ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel2ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel3ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel4ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel5ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel6ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel7ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.centralChannel8ColumnData),
                                    //TODO : LOCAL ECPH DATA
                                    Column(
                                      children: [
                                        for(var i in widget.localEcPhColumnData)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for(var j = 0;j < i.length;j++)
                                                Container(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  width: 100,
                                                  height: 50,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('${i[j] ?? '-'}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,),
                                                ),
                                              SizedBox(
                                                width: 0,
                                                height: 50,
                                                child: CustomPaint(
                                                  painter: VerticalDotBorder(),
                                                  size: Size(0,50),
                                                ),
                                              )

                                            ],
                                          )
                                      ],
                                    ),
                                    //TODO : LOCAL CHANNEL
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel1ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel2ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel3ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel4ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel5ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel6ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel7ColumnData),
                                    getChannnelColumnDataWidget(columnDataList: widget.localChannel8ColumnData),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          );
        },),
      ),
    );
  }
}

Widget getColumnDotLine(){
  return SizedBox(
    width: 0,
    height: 50,
    child: CustomPaint(
      painter: VerticalDotBorder(),
      size: Size(0,50),
    ),
  );
}

Widget getChannnelColumnDataWidget({required List<dynamic> columnDataList}){
  return Column(
    children: [
      for(var i in columnDataList)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for(var j = 0;j < i.length;j++)
              Container(
                padding: const EdgeInsets.only(left: 8),
                width: 100,
                height: 50,
                alignment: Alignment.centerLeft,
                child: Text('${i[j] ?? '-'}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,),
              ),
            SizedBox(
              width: 0,
              height: 50,
              child: CustomPaint(
                painter: VerticalDotBorder(),
                size: Size(0,50),
              ),
            )

          ],
        )
    ],
  );
}

Widget getChannelColumnWidget({required List<dynamic> columnList,required int channelNo,required bool central}){
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Center(
        child: Text('<${central ? 'C' : 'L'}-CH$channelNo>',style: TextStyle(color: Colors.white),),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(var i = 0;i < columnList.length;i++)
            Container(
              // color: Color(0xffEAEAEA),
              color: Colors.orange.shade200,
              padding: const EdgeInsets.only(left: 8),
              width: 100,
              height: 25,
              alignment: Alignment.centerLeft,
              child: Text('${columnList[i]}',style: TextStyle(color: Colors.black),),
            ),

        ],
      ),
    ],
  );
}


class VerticalDotBorder extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    Paint border = Paint();
    border.color = Colors.black;
    border.strokeWidth = 0.5;
    final double dashWidth = 5;
    final double dashSpace = 5;
    double currentY = 0;

    while (currentY < size.height) {
      canvas.drawLine(
          Offset(0, currentY), Offset(0, currentY + dashWidth), border);
      currentY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}
