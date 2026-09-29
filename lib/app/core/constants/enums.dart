import 'package:flutter/material.dart';

enum LoadStatus { pickup, inTransit, delivered }

/// Trip lifecycle as sent/received by the API (`status`).
enum TripStatus {
  draft('DRAFT', 'Draft'),
  pending('PENDING', 'Pending'),
  active('ACTIVE', 'Active'),
  paused('PAUSED', 'Paused'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled');

  const TripStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TripStatus fromApi(String? value) {
    for (final status in values) {
      if (status.apiValue == value?.toUpperCase()) return status;
    }
    return TripStatus.pending;
  }

  Color get color => switch (this) {
        TripStatus.active => const Color(0xFF1E8E5A),
        TripStatus.paused => const Color(0xFF3B6FB6),
        TripStatus.completed => const Color(0xFF1E8E5A),
        TripStatus.cancelled => const Color(0xFFC0392B),
        TripStatus.draft => const Color(0xFF6B6B6B),
        TripStatus.pending => const Color(0xFF8B6914),
      };

  Color get backgroundColor => switch (this) {
        TripStatus.active => const Color(0xFFDDF3E5),
        TripStatus.paused => const Color(0xFFDDE8F7),
        TripStatus.completed => const Color(0xFFDDF3E5),
        TripStatus.cancelled => const Color(0xFFF8DEDB),
        TripStatus.draft => const Color(0xFFEDEDED),
        TripStatus.pending => const Color(0xFFF5E6C8),
      };
}

/// Tabs on the Itinerary screen; [status] is the API filter (null = all).
enum ItineraryTab {
  all('All', null),
  pending('Pending', TripStatus.pending),
  ongoing('Active', TripStatus.active),
  paused('Paused', TripStatus.paused),
  completed('Completed', TripStatus.completed),
  cancelled('Cancelled', TripStatus.cancelled);

  const ItineraryTab(this.label, this.status);

  final String label;
  final TripStatus? status;
}

class SortProduct {
  static const newest = 'newest';
  static const priceLowToHigh = 'price_low_to_high';
  static const priceHighToLow = 'price_high_to_low';
  static const ratingHighToLow = 'rating_high_to_low';
  static const ratingLowToHigh = 'rating_low_to_high';
}

class OrderStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const packaging = 'packaging';
  static const outOfDelivery = 'out_of_delivery';
  static const delivered = 'delivered';
  static const failedToDeliver = 'failed_to_deliver';
  static const cancelled = 'cancelled';
  static const returned = 'returned';
}

class SaveAddressAs {
  static const home = 'home';
  static const office = 'office';
  static const other = 'other';
}
