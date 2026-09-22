import "dart:async";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart" hide RefreshIndicator;
import "package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart";

/// Builds a refresh indicator's content for a given [RefreshStatus].
typedef MobileDevToolRefreshContentBuilder =
    Widget Function(BuildContext context, RefreshStatus? status);

/// Builds a load-more indicator's content for a given [LoadStatus].
typedef MobileDevToolLoadMoreContentBuilder =
    Widget Function(BuildContext context, LoadStatus? status);

/// App-level defaults for every [MobileDevToolRefreshLoadMore] below this
/// widget.
///
/// This is a thin, namespaced wrapper around the package's
/// [RefreshConfiguration]. For example:
///
/// ```dart
/// MobileDevToolRefreshConfiguration(
///   headerBuilder: () => const MaterialClassicHeader(),
///   footerBuilder: () => const ClassicFooter(
///     loadingIcon: SizedBox.square(
///       dimension: 18,
///       child: CircularProgressIndicator(strokeWidth: 2),
///     ),
///   ),
///   child: MaterialApp(home: const HomePage()),
/// )
/// ```
class MobileDevToolRefreshConfiguration extends StatelessWidget {
  const MobileDevToolRefreshConfiguration({
    required this.child,
    this.headerBuilder,
    this.footerBuilder,
    this.dragSpeedRatio = 1.0,
    this.shouldFooterFollowWhenNotFull,
    this.enableScrollWhenTwoLevel = true,
    this.enableLoadingWhenNoData = false,
    this.enableBallisticRefresh = false,
    this.enableBallisticLoad = true,
    this.springDescription = const SpringDescription(
      mass: 2.2,
      stiffness: 150,
      damping: 16,
    ),
    this.enableScrollWhenRefreshCompleted = false,
    this.enableLoadingWhenFailed = true,
    this.twiceTriggerDistance = 150.0,
    this.closeTwoLevelDistance = 80.0,
    this.skipCanRefresh = false,
    this.maxOverScrollExtent,
    this.maxUnderScrollExtent,
    this.headerTriggerDistance = 80.0,
    this.footerTriggerDistance = 15.0,
    this.hideFooterWhenNotFull = false,
    this.enableRefreshVibrate = false,
    this.enableLoadMoreVibrate = false,
    this.topHitBoundary,
    this.bottomHitBoundary,
    super.key,
  });

  final Widget child;
  final IndicatorBuilder? headerBuilder;
  final IndicatorBuilder? footerBuilder;
  final double dragSpeedRatio;
  final ShouldFollowContent? shouldFooterFollowWhenNotFull;
  final bool enableScrollWhenTwoLevel;
  final bool enableLoadingWhenNoData;
  final bool enableBallisticRefresh;
  final bool enableBallisticLoad;
  final SpringDescription springDescription;
  final bool enableScrollWhenRefreshCompleted;
  final bool enableLoadingWhenFailed;
  final double twiceTriggerDistance;
  final double closeTwoLevelDistance;
  final bool skipCanRefresh;
  final double? maxOverScrollExtent;
  final double? maxUnderScrollExtent;
  final double headerTriggerDistance;
  final double footerTriggerDistance;
  final bool hideFooterWhenNotFull;
  final bool enableRefreshVibrate;
  final bool enableLoadMoreVibrate;
  final double? topHitBoundary;
  final double? bottomHitBoundary;

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerBuilder: headerBuilder,
      footerBuilder: footerBuilder,
      dragSpeedRatio: dragSpeedRatio,
      shouldFooterFollowWhenNotFull: shouldFooterFollowWhenNotFull,
      enableScrollWhenTwoLevel: enableScrollWhenTwoLevel,
      enableLoadingWhenNoData: enableLoadingWhenNoData,
      enableBallisticRefresh: enableBallisticRefresh,
      enableBallisticLoad: enableBallisticLoad,
      springDescription: springDescription,
      enableScrollWhenRefreshCompleted: enableScrollWhenRefreshCompleted,
      enableLoadingWhenFailed: enableLoadingWhenFailed,
      twiceTriggerDistance: twiceTriggerDistance,
      closeTwoLevelDistance: closeTwoLevelDistance,
      skipCanRefresh: skipCanRefresh,
      maxOverScrollExtent: maxOverScrollExtent,
      maxUnderScrollExtent: maxUnderScrollExtent,
      headerTriggerDistance: headerTriggerDistance,
      footerTriggerDistance: footerTriggerDistance,
      hideFooterWhenNotFull: hideFooterWhenNotFull,
      enableRefreshVibrate: enableRefreshVibrate,
      enableLoadMoreVibrate: enableLoadMoreVibrate,
      topHitBoundary: topHitBoundary,
      bottomHitBoundary: bottomHitBoundary,
      child: child,
    );
  }
}

/// A ready-to-use refresh and load-more wrapper for a scrollable child.
///
/// Refresh and load-more can be enabled independently. The callbacks are
/// asynchronous and this widget completes the corresponding indicator for
/// you:
///
/// * [onRefresh] completes or fails the header based on whether it throws.
/// * [onLoadMore] returns `true` when more data is available and `false` when
///   the end has been reached.
///
/// Pass [header] or [footer] to use any indicator shipped by
/// `pull_to_refresh_flutter3`, such as [MaterialClassicHeader] or
/// [ClassicFooter]. For state-aware custom UI, use [refreshBuilder] or
/// [loadMoreBuilder]. [loadMoreShimmerBuilder] replaces the footer content
/// while loading and is useful for a skeleton/shimmer widget. If [footer] is
/// supplied, it takes precedence over the custom footer builders.
class MobileDevToolRefreshLoadMore extends StatefulWidget {
  const MobileDevToolRefreshLoadMore({
    required this.child,
    this.controller,
    this.enableRefresh = true,
    this.enableLoadMore = false,
    this.onRefresh,
    this.onLoadMore,
    this.header,
    this.footer,
    this.refreshBuilder,
    this.loadMoreBuilder,
    this.loadMoreShimmerBuilder,
    this.refreshIndicatorHeight = 60.0,
    this.loadMoreIndicatorHeight = 60.0,
    this.refreshStyle = RefreshStyle.Follow,
    this.loadStyle = LoadStyle.ShowWhenLoading,
    this.scrollDirection,
    this.reverse,
    this.scrollController,
    this.primary,
    this.physics,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior,
    super.key,
  }) : assert(
         !enableRefresh || onRefresh != null,
         "onRefresh is required when enableRefresh is true",
       ),
       assert(
         !enableLoadMore || onLoadMore != null,
         "onLoadMore is required when enableLoadMore is true",
       ),
       assert(
         header == null || refreshBuilder == null,
         "Use either header or refreshBuilder, not both",
       ),
       assert(
         footer == null || loadMoreBuilder == null,
         "Use either footer or loadMoreBuilder, not both",
       );

  final Widget child;

  /// Supply a controller when the host needs to call requestRefresh,
  /// requestLoading, or inspect/reset indicator state manually.
  final RefreshController? controller;

  final bool enableRefresh;
  final bool enableLoadMore;
  final FutureOr<void> Function()? onRefresh;

  /// Return `true` if another page exists; return `false` to show no-more.
  final FutureOr<bool> Function()? onLoadMore;

  /// A [RefreshIndicator] from the library, e.g. [ClassicHeader] or
  /// [MaterialClassicHeader].
  final RefreshIndicator? header;

  /// A [LoadIndicator] from the library, e.g. [ClassicFooter] or
  /// [CustomFooter].
  final LoadIndicator? footer;

  /// State-aware custom header content. Internally creates [CustomHeader].
  final MobileDevToolRefreshContentBuilder? refreshBuilder;

  /// State-aware custom footer content. Internally creates [CustomFooter].
  final MobileDevToolLoadMoreContentBuilder? loadMoreBuilder;

  /// Optional content used only while [LoadStatus.loading]. This can be a
  /// shimmer/skeleton widget from the host app.
  final WidgetBuilder? loadMoreShimmerBuilder;

  final double refreshIndicatorHeight;
  final double loadMoreIndicatorHeight;
  final RefreshStyle refreshStyle;
  final LoadStyle loadStyle;
  final Axis? scrollDirection;
  final bool? reverse;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior? dragStartBehavior;

  @override
  State<MobileDevToolRefreshLoadMore> createState() =>
      _MobileDevToolRefreshLoadMoreState();
}

class _MobileDevToolRefreshLoadMoreState
    extends State<MobileDevToolRefreshLoadMore> {
  late final RefreshController _ownedController;

  RefreshController get _controller => widget.controller ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = RefreshController();
  }

  @override
  void dispose() {
    _ownedController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    try {
      await widget.onRefresh!();
      _controller.refreshCompleted();
    } catch (_) {
      _controller.refreshFailed();
      rethrow;
    }
  }

  Future<void> _handleLoadMore() async {
    try {
      final hasMore = await widget.onLoadMore!();
      if (hasMore) {
        _controller.loadComplete();
      } else {
        _controller.loadNoData();
      }
    } catch (_) {
      _controller.loadFailed();
      rethrow;
    }
  }

  Widget? _buildHeader() {
    if (widget.header != null) return widget.header;
    final builder = widget.refreshBuilder;
    if (builder == null) return null;

    return CustomHeader(
      height: widget.refreshIndicatorHeight,
      refreshStyle: widget.refreshStyle,
      builder: builder,
    );
  }

  Widget? _buildFooter() {
    if (widget.footer != null) return widget.footer;
    final builder = widget.loadMoreBuilder;
    final shimmerBuilder = widget.loadMoreShimmerBuilder;
    if (builder == null && shimmerBuilder == null) return null;

    return CustomFooter(
      height: widget.loadMoreIndicatorHeight,
      loadStyle: widget.loadStyle,
      builder: (context, status) {
        if (status == LoadStatus.loading && shimmerBuilder != null) {
          return shimmerBuilder(context);
        }
        if (builder != null) return builder(context, status);
        return _defaultLoadMoreContent(context, status);
      },
    );
  }

  Widget _defaultLoadMoreContent(BuildContext context, LoadStatus? status) {
    return switch (status) {
      LoadStatus.loading => const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      LoadStatus.noMore => const Text("Đã tải hết dữ liệu"),
      LoadStatus.failed => const Text("Tải thêm thất bại"),
      LoadStatus.canLoading => const Text("Thả để tải thêm"),
      LoadStatus.idle || null => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      enablePullDown: widget.enableRefresh,
      enablePullUp: widget.enableLoadMore,
      onRefresh: widget.enableRefresh ? _handleRefresh : null,
      onLoading: widget.enableLoadMore ? _handleLoadMore : null,
      header: _buildHeader(),
      footer: _buildFooter(),
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      scrollController: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      child: widget.child,
    );
  }
}
