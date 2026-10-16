import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import "package:mobile_sdk_firebase_core/mobile_sdk_firebase_core.dart"
    as firebase;

class _FakeApp extends Fake implements FirebaseApp {}

class _Adapter implements firebase.Adapter {
  _Adapter(this.module, this.calls, {this.fail = false});

  @override
  final firebase.Module module;
  final List<String> calls;
  final bool fail;

  @override
  Future<void> initialize(FirebaseApp app, firebase.Privacy privacy) async {
    calls.add('start:${module.name}');
    if (fail) throw StateError('failed');
  }

  @override
  Future<void> dispose() async => calls.add('dispose:${module.name}');
}

void main() {
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
