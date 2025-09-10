import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImageUtils {
  static Future<Uint8List> generatePlaceholderImage({
    required int width,
    required int height,
    Color backgroundColor = Colors.grey,
    String? text,
    Color textColor = Colors.white,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());
    
    // Draw background
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, paint);
    
    // Draw text if provided
    if (text != null) {
      final textStyle = TextStyle(
        color: textColor,
        fontSize: width * 0.1,
        fontWeight: FontWeight.bold,
      );
      
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      final offset = Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      );
      textPainter.paint(canvas, offset);
    }
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  
  static Widget buildPlaceholderImage({
    required double width,
    required double height,
    String? text,
    Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
  }) {
    return FutureBuilder<Uint8List>(
      future: generatePlaceholderImage(
        width: width.toInt(),
        height: height.toInt(),
        text: text,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: width,
          height: height,
          color: backgroundColor,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
