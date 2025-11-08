import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

// const ButtonStyle socialButtonStyle = ButtonStyle(
//   side: WidgetStatePropertyAll(
//     BorderSide(color: accentAmber, width: 1)
//   ),
//   minimumSize: WidgetStatePropertyAll(
//     Size(double.infinity, 50)
//   ),
//   shape: WidgetStatePropertyAll(
//     RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(8.0)),
//     )
//   ),
//   padding: WidgetStatePropertyAll(
//     EdgeInsets.symmetric(vertical: 12.0)
//   ),
// );

class SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,

      // ButtonStyle
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey[100],
          foregroundColor: Colors.white,
          minimumSize: Size(60, 32),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
      ),

      // Contents
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Handles the Icon
          SizedBox(
          width: 24.0,
          child: Align(
            alignment: Alignment.centerRight,
            child: icon, 
            ),
          ),
          const SizedBox(width: 8.0),

          // Button text
          Text(
            label,
            style: const TextStyle(
              color: greenPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

