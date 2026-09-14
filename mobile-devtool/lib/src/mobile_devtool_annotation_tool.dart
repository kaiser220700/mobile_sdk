import "package:flutter/material.dart";

/// [idle] = pan-through mode (like Figma's hand tool) — taps/drags pass
/// through to the real app instead of drawing. [select] = pick an existing
/// annotation to delete it.
enum MobileDevToolAnnotationShape {
  idle,
  select,
  rectangle,
  circle,
  arrow,
  line,
  tooltip,
}

const List<double> mobileDevToolAnnotationFontSizeOptions = [10, 12, 16];

class MobileDevToolAnnotation {
  const MobileDevToolAnnotation({
    required this.id,
    required this.shape,
    required this.start,
    required this.end,
    required this.color,
    required this.routeKey,
    this.text = "",
    this.textColor,
    this.fontSize,
  });

  final int id;
  final MobileDevToolAnnotationShape shape;
  final Offset start;
  final Offset end;
  final Color color;
  final String text;

  /// Route key at draw time — only annotations matching the current route are
  /// shown, see [MobileDevToolAnnotationTool.visibleAnnotations].
  final String routeKey;

  final Color? textColor;
  final double? fontSize;

  MobileDevToolAnnotation copyWith({
    Offset? end,
    String? text,
    Color? textColor,
    double? fontSize,
  }) => MobileDevToolAnnotation(
    id: id,
    shape: shape,
    start: start,
    end: end ?? this.end,
    color: color,
    routeKey: routeKey,
    text: text ?? this.text,
    textColor: textColor ?? this.textColor,
    fontSize: fontSize ?? this.fontSize,
  );
}

/// Sentinel route key before the first navigation event fires.
const mobileDevToolAnnotationUnknownRoute = "<initial>";

/// Single `ChangeNotifier` bag for all screen-annotation state — mirrors the
/// style of `MobileDevToolController`, avoiding a dependency on any
/// state-management library.
class MobileDevToolAnnotationTool extends ChangeNotifier {
  MobileDevToolAnnotationTool({Color? accentColor})
    : _accentColor = accentColor ?? const Color(0xFF2196F3) {
    _activeColor = colorPalette.first;
    _activeTextColor = const Color(0xFFFFFFFF);
  }

  final Color _accentColor;

  List<Color> get colorPalette => [
    _accentColor,
    const Color(0xFFE53935),
    const Color(0xFF43A047),
    const Color(0xFF1E88E5),
    const Color(0xFFFDD835),
    const Color(0xFF000000),
  ];

  List<MobileDevToolAnnotation> _annotations = const [];
  MobileDevToolAnnotationShape _activeShape = MobileDevToolAnnotationShape.idle;
  late Color _activeColor;
  late Color _activeTextColor;
  double _activeFontSize = mobileDevToolAnnotationFontSizeOptions[1];
  int? _selectedId;
  bool _overlayActive = false;
  bool _toolbarCollapsed = false;
  Offset? _toolbarPosition;
  String _currentRouteKey = mobileDevToolAnnotationUnknownRoute;
  Offset _scrollOffset = Offset.zero;
  int _nextId = 0;

  List<MobileDevToolAnnotation> get visibleAnnotations =>
      _annotations.where((a) => a.routeKey == _currentRouteKey).toList();

  MobileDevToolAnnotationShape get activeShape => _activeShape;
  Color get activeColor => _activeColor;
  Color get activeTextColor => _activeTextColor;
  double get activeFontSize => _activeFontSize;
  int? get selectedId => _selectedId;
  bool get overlayActive => _overlayActive;
  bool get toolbarCollapsed => _toolbarCollapsed;
  Offset? get toolbarPosition => _toolbarPosition;
  String get currentRouteKey => _currentRouteKey;
  Offset get scrollOffset => _scrollOffset;

  void selectShape(MobileDevToolAnnotationShape shape) {
    _activeShape = shape;
    notifyListeners();
  }

  void selectColor(Color color) {
    _activeColor = color;
    notifyListeners();
  }

  void selectTextColor(Color color) {
    _activeTextColor = color;
    notifyListeners();
  }

  void selectFontSize(double size) {
    _activeFontSize = size;
    notifyListeners();
  }

  void selectAnnotation(int? id) {
    _selectedId = id;
    notifyListeners();
  }

  void showOverlay() {
    _overlayActive = true;
    notifyListeners();
  }

  void hideOverlay() {
    _overlayActive = false;
    notifyListeners();
  }

  void toggleToolbarCollapsed() {
    _toolbarCollapsed = !_toolbarCollapsed;
    notifyListeners();
  }

  set toolbarPosition(Offset value) {
    _toolbarPosition = value;
    notifyListeners();
  }

  /// Also resets the scroll offset — a route change makes the previous
  /// page's accumulated scroll delta meaningless for the new page.
  void updateRoute(String routeKey) {
    if (routeKey == _currentRouteKey) return;
    _currentRouteKey = routeKey;
    _scrollOffset = Offset.zero;
    notifyListeners();
  }

  void addScrollDelta(Offset delta) {
    _scrollOffset += delta;
    notifyListeners();
  }

  void resetScroll() {
    _scrollOffset = Offset.zero;
    notifyListeners();
  }

  void begin(
    MobileDevToolAnnotationShape shape,
    Offset position, {
    required Offset scrollOffset,
    required Color color,
    Color? textColor,
    double? fontSize,
  }) {
    final world = position + scrollOffset;
    _annotations = [
      ..._annotations,
      MobileDevToolAnnotation(
        id: _nextId++,
        shape: shape,
        start: world,
        end: world,
        color: color,
        routeKey: _currentRouteKey,
        textColor: textColor,
        fontSize: fontSize,
      ),
    ];
    notifyListeners();
  }

  int? _lastIndexForCurrentRoute() {
    for (var i = _annotations.length - 1; i >= 0; i--) {
      if (_annotations[i].routeKey == _currentRouteKey) return i;
    }
    return null;
  }

  int? get lastId {
    final index = _lastIndexForCurrentRoute();
    return index == null ? null : _annotations[index].id;
  }

  void updateLast(Offset position, {required Offset scrollOffset}) {
    final index = _lastIndexForCurrentRoute();
    if (index == null) return;
    final updated = [..._annotations];
    updated[index] = updated[index].copyWith(end: position + scrollOffset);
    _annotations = updated;
    notifyListeners();
  }

  void setTooltipStyleForId(
    int id, {
    String? text,
    Color? textColor,
    double? fontSize,
  }) {
    _annotations = [
      for (final a in _annotations)
        if (a.id == id)
          a.copyWith(text: text, textColor: textColor, fontSize: fontSize)
        else
          a,
    ];
    notifyListeners();
  }

  void removeLast() {
    final index = _lastIndexForCurrentRoute();
    if (index == null) return;
    _annotations = [..._annotations]..removeAt(index);
    notifyListeners();
  }

  void removeById(int id) {
    _annotations = _annotations.where((a) => a.id != id).toList();
    notifyListeners();
  }

  void clear() {
    _annotations = _annotations
        .where((a) => a.routeKey != _currentRouteKey)
        .toList();
    notifyListeners();
  }
}
