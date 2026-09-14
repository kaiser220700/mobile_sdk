import "package:flutter/material.dart";

class PreviewDefinition {
  const PreviewDefinition({
    required this.id,
    required this.category,
    required this.html,
    required this.flutterWidget,
    required this.description,
    required this.builder,
  });

  final String id;
  final String category;
  final String html;
  final String flutterWidget;
  final String description;
  final WidgetBuilder builder;
}

const previewCategories = [
  "all",
  "foundation",
  "actions",
  "forms",
  "feedback",
  "navigation",
  "data",
  "overlay",
  "layout",
  "disclosure",
  "interaction",
  "motion",
  "typography",
];
