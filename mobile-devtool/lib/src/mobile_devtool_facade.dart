import "mobile_devtool_controller.dart";

/// Optional convenience for hosts that don't thread a
/// [MobileDevToolController] through their own DI container — call
/// [attachInstance] once at the composition root (wherever the controller is
/// created), then record from anywhere without holding a reference.
///
/// Hosts with an existing DI framework (Riverpod, get_it, Provider...) should
/// inject [MobileDevToolController] directly instead and skip this facade
/// entirely — it exists only for call sites that have no DI access at all.
/// Both styles operate on the same controller instance, so a host is free to
/// mix them.
class MobileDevTool {
  MobileDevTool._();

  static MobileDevToolController? _instance;

  static void attachInstance(MobileDevToolController controller) =>
      _instance = controller;

  static void detachInstance() => _instance = null;

  static void trace(String message) => _instance?.recordTrace(message);

  /// Returns `""` (a no-op id, same as [MobileDevToolController.disabled])
  /// when no instance has been attached yet.
  static String startNetwork(MobileDevToolNetworkRequest request) =>
      _instance?.startNetwork(request) ?? "";

  static void completeNetwork(
    String id, {
    dynamic response,
    int? statusCode,
    Duration? duration,
  }) => _instance?.completeNetwork(
    id,
    response: response,
    statusCode: statusCode,
    duration: duration,
  );

  static void failNetwork(
    String id, {
    required Object error,
    dynamic response,
    int? statusCode,
    Duration? duration,
  }) => _instance?.failNetwork(
    id,
    error: error,
    response: response,
    statusCode: statusCode,
    duration: duration,
  );
}
