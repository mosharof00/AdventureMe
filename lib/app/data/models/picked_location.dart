/// A point chosen on the Select Location screen.
class PickedLocation {
  final double lat;
  final double lng;
  final String? address;

  const PickedLocation({required this.lat, required this.lng, this.address});

  /// Address, or the coordinates when no address is known.
  String get label =>
      address?.trim().isNotEmpty == true
          ? address!
          : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}
