enum ServicesSort {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  newest,
}

class ServicesFilter {
  final String? category;
  final int? minRating;
  final double? minPrice;
  final double? maxPrice;
  final ServicesSort sort;

  const ServicesFilter({
    this.category,
    this.minRating,
    this.minPrice,
    this.maxPrice,
    this.sort = ServicesSort.relevance,
  });

  ServicesFilter copyWith({
    String? category,
    int? minRating,
    double? minPrice,
    double? maxPrice,
    ServicesSort? sort,
  }) {
    return ServicesFilter(
      category: category ?? this.category,
      minRating: minRating ?? this.minRating,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }

  static const empty = ServicesFilter();
}
