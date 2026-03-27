import 'package:flutter/material.dart';

enum MediaType { image, gif, video }

class MediaFile {
  final String id;
  final String path;
  final MediaType type;
  final String name;
  
  MediaFile({
    required this.id,
    required this.path,
    required this.type,
    required this.name,
  });
}

class Tag {
  final String id;
  final String name;
  final String category;
  final int usageCount;
  final Color color;
  
  Tag({
    required this.id,
    required this.name,
    required this.category,
    required this.usageCount,
    required this.color,
  });
}