class VisitedCountriesResponse {
  final bool? success;
  final String? message;
  final VisitedCountriesData? data;

  const VisitedCountriesResponse({
    this.success,
    this.message,
    this.data,
  });

  factory VisitedCountriesResponse.fromJson(Map<String, dynamic> json) {
    return VisitedCountriesResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? VisitedCountriesData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VisitedCountriesData {
  final int totalVisitedCountries;
  final int totalWorldCountries;
  final double worldPercentage;
  final int worldPercentageRounded;
  final String summaryText;
  final VisitedCountriesMeta? meta;

  const VisitedCountriesData({
    this.totalVisitedCountries = 0,
    this.totalWorldCountries = 195,
    this.worldPercentage = 0.0,
    this.worldPercentageRounded = 0,
    this.summaryText = '',
    this.meta,
  });

  factory VisitedCountriesData.fromJson(Map<String, dynamic> json) {
    return VisitedCountriesData(
      totalVisitedCountries:
          (json['totalVisitedCountries'] as num?)?.toInt() ?? 0,
      totalWorldCountries:
          (json['totalWorldCountries'] as num?)?.toInt() ?? 195,
      worldPercentage:
          (json['worldPercentage'] as num?)?.toDouble() ?? 0.0,
      worldPercentageRounded:
          (json['worldPercentageRounded'] as num?)?.toInt() ?? 0,
      summaryText: json['summaryText']?.toString() ?? '',
      meta: json['meta'] is Map<String, dynamic>
          ? VisitedCountriesMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VisitedCountriesMeta {
  final int evaluatedTripsCount;
  final String? statusFilter;

  const VisitedCountriesMeta({
    this.evaluatedTripsCount = 0,
    this.statusFilter,
  });

  factory VisitedCountriesMeta.fromJson(Map<String, dynamic> json) {
    return VisitedCountriesMeta(
      evaluatedTripsCount:
          (json['evaluatedTripsCount'] as num?)?.toInt() ?? 0,
      statusFilter: json['statusFilter']?.toString(),
    );
  }
}
