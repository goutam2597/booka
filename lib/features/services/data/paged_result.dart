class PagedResult<T> {
  final List<T> items;
  final int totalCount; // if unknown, set to items.length or -1 and handle upstream
  final bool hasMore;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });
}
