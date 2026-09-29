import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sdk_firebase_core/mobile_sdk_firebase_core.dart';

class _FakeApp extends Fake implements FirebaseApp {}

class _Adapter implements MobileFirebaseAdapter {
  _Adapter(this.module, this.calls, {this.fail = false});

  @override
  final MobileFirebaseModule module;
  final List<String> calls;
  final bool fail;

  @override
  Future<void> initialize(
    FirebaseApp app,
    MobileFirebasePrivacy privacy,
  ) async {
    calls.add('start:${module.name}');
    if (fail) throw StateError('failed');
  }

  @override
  Future<void> dispose() async => calls.add('dispose:${module.name}');
}

void main() {
  test('starts selected modules and disposes in reverse order once', () async {
    final calls = <String>[];
    final runtime = await MobileFirebase.initialize(
      app: _FakeApp(),
      modules: {
        MobileFirebaseModule.analytics,
        MobileFirebaseModule.remoteConfig,
      },
      privacy: const MobileFirebasePrivacy(),
      adapters: [
        _Adapter(MobileFirebaseModule.analytics, calls),
        _Adapter(MobileFirebaseModule.remoteConfig, calls),
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
      MobileFirebase.initialize(
        app: _FakeApp(),
        modules: {
          MobileFirebaseModule.analytics,
          MobileFirebaseModule.remoteConfig,
        },
        privacy: const MobileFirebasePrivacy(),
        adapters: [
          _Adapter(MobileFirebaseModule.analytics, calls),
          _Adapter(MobileFirebaseModule.remoteConfig, calls, fail: true),
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
