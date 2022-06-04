import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color background;
  final Color borderColor;
  final String text;
  final Color textColor;
  const FollowButton({
    Key? key,
    required this.background,
    required this.borderColor,
    required this.text,
    required this.textColor,
    this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: 220,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
