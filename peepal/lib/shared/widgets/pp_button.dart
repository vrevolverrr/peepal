import 'package:flutter/material.dart';

class PPButton extends StatelessWidget {
  final String text;
  final double? height;
  final double? width;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PPButton(this.text,
      {super.key,
      this.onPressed,
      this.height,
      this.width,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 4.0,
          backgroundColor: !isLoading ? Colors.blueAccent : Colors.grey,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50.0),
          shape: RoundedRectangleBorder(
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
