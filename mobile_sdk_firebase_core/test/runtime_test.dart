import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import "package:mobile_sdk_firebase_core/mobile_sdk_firebase_core.dart"
    as firebase;

class _FakeApp extends Fake implements FirebaseApp {}

class _Adapter implements firebase.Adapter {
  _Adapter(
    this.module,
    this.calls, {
    this.fail = false,
    this.failDispose = false,
  });

  @override
  final firebase.Module module;
  final List<String> calls;
  final bool fail;
  final bool failDispose;

  @override
  Future<void> initialize(FirebaseApp app, firebase.Privacy privacy) async {
    calls.add('start:${module.name}');
    if (fail) throw StateError('failed');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose:${module.name}');
    if (failDispose) throw StateError('dispose failed');
  }
}

void main() {
  test('disposes remaining adapters even when one cleanup fails', () async {
    final calls = <String>[];
    final runtime = await firebase.Bootstrap.initialize(
      app: _FakeApp(),
      modules: {firebase.Module.analytics, firebase.Module.remoteConfig},
      privacy: const firebase.Privacy(),
      adapters: [
        _Adapter(firebase.Module.analytics, calls),
        _Adapter(firebase.Module.remoteConfig, calls, failDispose: true),
      ],
    );
    await expectLater(runtime.dispose(), throwsStateError);
    expect(
      calls,
      containsAllInOrder(['dispose:remoteConfig', 'dispose:analytics']),
    );
  });

  test('starts selected modules and disposes in reverse order once', () async {
    final calls = <String>[];
    final runtime = await firebase.Bootstrap.initialize(
      app: _FakeApp(),
      modules: {firebase.Module.analytics, firebase.Module.remoteConfig},
      privacy: const firebase.Privacy(),
      adapters: [
        _Adapter(firebase.Module.analytics, calls),
        _Adapter(firebase.Module.remoteConfig, calls),
      ],
    );
    await runtime.dispose();
    await runtime.dispose();
    expect(calls, [
      'start:analytics',
      'start:remoteConfig',
      'dispose:remoteConfig',
      'dispose:analytics',
    ]);
  });

  test('cleans the failing adapter and earlier adapters', () async {
    final calls = <String>[];
    await expectLater(
      firebase.Bootstrap.initialize(
        app: _FakeApp(),
        modules: {firebase.Module.analytics, firebase.Module.remoteConfig},
        privacy: const firebase.Privacy(),
        adapters: [
          _Adapter(firebase.Module.analytics, calls),
          _Adapter(firebase.Module.remoteConfig, calls, fail: true),
        ],
      ),
      throwsStateError,
    );
    expect(calls, [
      'start:analytics',
      'start:remoteConfig',
      'dispose:remoteConfig',
      'dispose:analytics',
    ]);
  });
}
