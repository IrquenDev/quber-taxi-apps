class Page<T> {
  final List<T> content;
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;

  Page({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory Page.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return Page<T>(
      content: (json['content'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      number: json['number'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? true,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
    'content': content.map((item) => toJsonT(item)).toList(),
    'number': number,
    'size': size,
    'totalElements': totalElements,
    'totalPages': totalPages,
    'first': first,
    'last': last,
    'empty': empty,
  };
} 