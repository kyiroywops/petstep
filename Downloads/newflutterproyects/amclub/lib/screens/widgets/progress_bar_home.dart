import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value; // Valor entre 0.0 y 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final int totalDivisions; // Número total de divisiones o fases

  const CustomProgressIndicator({
    Key? key,
    required this.value,
    this.height = 20.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.totalDivisions = 4, // Por ejemplo, divide en 4 fases
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          double progressWidth = maxWidth * value;

          List<Widget> progressDivisions = List.generate(
            totalDivisions, (index) {
              bool isFilled = (index < value * totalDivisions);
              double divisionWidth = maxWidth / totalDivisions;
              bool isLastFilled = value * totalDivisions >= totalDivisions;
              BoxDecoration decoration = BoxDecoration(
                color: isFilled ? progressColor : Colors.transparent,
                borderRadius: BorderRadius.horizontal(
                  left: index == 0 ? Radius.circular(height / 2) : Radius.zero,
                  right: index == totalDivisions - 1 && isLastFilled ? Radius.circular(height / 2) : Radius.zero,
                ),
                border: index < totalDivisions - 1 ? Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 2)
                ) : null,
              );

              return Container(
                width: divisionWidth,
                decoration: decoration,
              );
            }
          );

          return Stack(
            children: [
              Row(children: progressDivisions),
              if (value >= 1.0) Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: height / 2,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    FontAwesomeIcons.solidCircleCheck,
                    color: Colors.greenAccent.shade400,
                    size: height * 0.75,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
