import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Captures a [RepaintBoundary] identified by [boundaryKey] and encodes it
/// as a PNG.
///
/// The caller is responsible for mounting the widget being captured inside a
/// `RepaintBoundary(key: boundaryKey)` while the export runs. [pixelRatio]
/// controls the output resolution relative to logical pixels; defaults to
/// 3× which produces sharp images on most screens without being huge.
class NavLensPngExporter {
  const NavLensPngExporter();

  Future<Uint8List> export({
    required GlobalKey boundaryKey,
    double pixelRatio = 3.0,
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      throw StateError(
        'NavLensPngExporter.export was called with a GlobalKey that is not '
        'attached to any RepaintBoundary. Ensure the tree containing the '
        'boundary is currently built before exporting.',
      );
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError(
        'NavLensPngExporter.export expected a RenderRepaintBoundary but '
        'found ${renderObject.runtimeType}. The provided GlobalKey must be '
        'attached to a RepaintBoundary widget.',
      );
    }
    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode captured image as PNG.');
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
