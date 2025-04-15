import 'package:flutter/material.dart';

class PPButton extends StatelessWidget {
  final String text;
  final double? height;
  final double? width;
  final bool isLoading;
  final bool outline;
  final VoidCallback? onPressed;

  const PPButton(this.text,
      {super.key,
      this.onPressed,
      this.height,
      this.width,
      this.outline = false,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: outline ? 0.0 : 4.0,
          backgroundColor: !isLoading
              ? (outline ? Colors.transparent : Colors.blueAccent)
              : Colors.grey,
          foregroundColor: !isLoading
              ? (outline ? Colors.blueAccent : Colors.white)
              : Colors.white,
          minimumSize: const Size.fromHeight(50.0),
          shape: RoundedRectangleBorder(
            side: !isLoading
                ? BorderSide(color: Colors.blueAccent)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
