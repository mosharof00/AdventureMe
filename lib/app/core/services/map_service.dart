import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/picked_location.dart';

/// Google-Maps helpers shared by the map screens. Permissions live in
/// `PermissionService`.
class MapService extends GetxService {
  /// This platform's Google Maps API key from the `.env` file.
  String get apiKey =>
      dotenv
          .env[Platform.isIOS
              ? 'GOOGLE_MAPS_IOS_API_KEY'
              : 'GOOGLE_MAPS_ANDROID_API_KEY']
          ?.trim() ??
      '';

  bool get hasApiKey => apiKey.isNotEmpty;

  double get _dpr => ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

  final _geocoding = Geocoding();

  /// Readable address for a coordinate via the OS geocoder (no API cost).
  Future<String?> addressFrom(double lat, double lng) async {
    try {
      final places = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (places.isEmpty) return null;
      final p = places.first;
      final parts = <String>[];
      for (final part in [
        p.name,
        p.street,
        p.subLocality,
        p.locality,
        p.country,
      ]) {
        final value = part?.trim() ?? '';
        if (value.isEmpty ||
            parts.any((x) => x.contains(value) || value.contains(x))) {
          continue;
        }
        parts.add(value);
      }
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  /// Places matching [query] via the OS geocoder, with readable addresses.
  Future<List<PickedLocation>> searchPlaces(String query, {int limit = 5}) async {
    final text = query.trim();
    if (text.length < 2) return const [];
    try {
      final locations = await _geocoding.locationFromAddress(text);
      return [
        for (final l in locations.take(limit))
          PickedLocation(
            lat: l.latitude,
            lng: l.longitude,
            address: await addressFrom(l.latitude, l.longitude) ?? text,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Rasterizes an SVG asset into a marker icon [width] logical pixels wide.
  Future<BitmapDescriptor> markerIconFromSvg(
    String assetPath, {
    double width = 42,
  }) async {
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetPath), null);
    final scale = (width * _dpr) / pictureInfo.size.width;

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..scale(scale)
      ..drawPicture(pictureInfo.picture);
    final image = await recorder.endRecording().toImage(
      (pictureInfo.size.width * scale).round(),
      (pictureInfo.size.height * scale).round(),
    );
    pictureInfo.picture.dispose();
    return _toDescriptor(image);
  }

  /// A pill with [text] and a pointer at the bottom; anchor it at (0.5, 1).
  Future<BitmapDescriptor> labelMarker(
    String text, {
    required Color color,
    Color textColor = Colors.white,
    double fontSize = 12,
  }) async {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padH = 10.0, padV = 6.0, pointer = 6.0, border = 2.0;
    final width = painter.width + padH * 2;
    final pillHeight = painter.height + padV * 2;
    final height = pillHeight + pointer;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(_dpr);
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, pillHeight),
      Radius.circular(pillHeight / 2),
    );
    final arrow = Path()
      ..moveTo(width / 2 - pointer, pillHeight - 1)
      ..lineTo(width / 2, height)
      ..lineTo(width / 2 + pointer, pillHeight - 1)
      ..close();

    canvas
      ..drawRRect(pill, Paint()..color = Colors.white)
      ..drawPath(arrow, Paint()..color = Colors.white)
      ..drawRRect(pill.deflate(border), Paint()..color = color)
      ..drawPath(
        arrow.shift(const Offset(0, -border)),
        Paint()..color = color,
      );
    painter.paint(canvas, Offset(padH, padV));

    final image = await recorder.endRecording().toImage(
      (width * _dpr).ceil(),
      (height * _dpr).ceil(),
    );
    return _toDescriptor(image);
  }

  /// A numbered circle; anchor it at (0.5, 0.5).
  Future<BitmapDescriptor> numberMarker(
    int number, {
    required Color color,
    double size = 28,
  }) async {
    final painter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(_dpr);
    final center = Offset(size / 2, size / 2);
    canvas
      ..drawCircle(center, size / 2, Paint()..color = Colors.white)
      ..drawCircle(center, size / 2 - 2.5, Paint()..color = color);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      (size * _dpr).ceil(),
      (size * _dpr).ceil(),
    );
    return _toDescriptor(image);
  }

  /// Decodes a Google encoded polyline string.
  List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      for (var i = 0; i < 2; i++) {
        var shift = 0, result = 0, byte = 0;
        do {
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20 && index < encoded.length);
        final delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
        if (i == 0) {
          lat += delta;
        } else {
          lng += delta;
        }
      }
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  LatLngBounds boundsOf(List<LatLng> points) {
    var minLat = points.first.latitude, maxLat = minLat;
    var minLng = points.first.longitude, maxLng = minLng;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<BitmapDescriptor> _toDescriptor(ui.Image image) async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: _dpr,
    );
  }
}
