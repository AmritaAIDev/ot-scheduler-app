import 'package:flutter/material.dart';
import 'package:my_flutter_app/config/customThemes/elevatedButtonTheme.dart';

class CustomCard extends StatelessWidget {
  final String data;
  final String title;
  final String imagePath;
  final double imageOpacity;
  final double elevation;
  final double borderRadius;
  final Color shadowColor;
  final VoidCallback onPressed;

  CustomCard({
    required this.data,
    required this.title,
    required this.imagePath,
    required this.onPressed,
    this.imageOpacity = 0.4,
    this.elevation = 3.0,
    this.borderRadius = 10.0,
    this.shadowColor = Colors.black26,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      shadowColor: shadowColor,
      child: Center(
        child: Container(
          width: 260,
          height: 340,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 5,
                blurRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(imageOpacity), // Adjusted opacity to make image clearer
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  data,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 128,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0,bottom: 16.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                // child: Text(
                //   subtitle,
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 16,
                //   ),
                // ),
                child: ElevatedButton(
                  onPressed: onPressed,
                    style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
                    child: Text('View Details',style: TextStyle(color: Colors.white),),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
