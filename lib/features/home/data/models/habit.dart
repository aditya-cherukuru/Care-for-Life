import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData iconData;
  
  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconData,
  });
  
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      iconData: IconData(
        json['iconData'] as int,
        fontFamily: 'MaterialIcons',
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'iconData': iconData.codePoint,
    };
  }
}