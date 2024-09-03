import 'package:flutter/material.dart';

class AdditionalInformation extends StatelessWidget {
  final String label;
  final String value;
  final String assetImage;
  final String Max;
  final String Min;

  const AdditionalInformation(
      {super.key,
      required this.label,
      required this.value,
      required this.assetImage,
      required this.Max,
      required this.Min});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Image.asset(
              assetImage,
              width: 85,
              height: 80,
              fit: BoxFit.scaleDown,
            ),
            const SizedBox(
              height: 22,
            ),
            label != "WindDirection" ? Text(
              "Max : $Max",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ) : Text(''),
            const SizedBox(
              height: 3,
            ),
            label != "WindDirection" ? Text(
              "Min :  $Min",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ) : Text(''),
          ],
        ),
        const SizedBox(
          width: 25,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 0, 65.0),
          child: Column(
            children: [
              Text(
                label == "AtmospherePressure" ? "AirPressure" : label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
                width: 0,
              ),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent),
              )
            ],
          ),
        ),
        SizedBox(
          width: 00,
        ),
      ],
    );
  }
}
