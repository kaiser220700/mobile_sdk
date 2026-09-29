# Firebase rollout in this repository

The blueprint is copied to [firebase-blueprint.md](firebase-blueprint.md). Its
`packages/` tree is a proposed layout. This repository already uses root-level
packages, so new packages follow that layout to preserve existing path imports.

## Available now

- `mobile_sdk_core`: typed configuration schema, immutable snapshots, validation,
  source and telemetry contracts, in-memory fakes. It has no FlutterFire dependency.
- `mobile_sdk_firebase_core`: host-owned `FirebaseApp`, selected adapter lifecycle,
  privacy settings, startup rollback and disposal. It depends only on `firebase_core`.
- `mobile_sdk_firebase_remote_config`: Firebase transport, typed config source,
  cache/default/fetch/realtime snapshots and failure fallback. This package alone
  adds the Remote Config plugin.
- `mobile_update`: a force-update decision requires a valid HTTPS or native store
  URI so an invalid remote config cannot block app use.

## Remaining rollout

Analytics, Crashlytics, Performance, Messaging, App Check and In-App Messaging
adapters, the all-in facade, app flavor integration, Console runbooks and native
CI/Distribution/Test Lab smoke runs are not implemented yet. They need project
Firebase configuration and, for push/App Check, host BFF contracts. Do not turn
on App Check enforcement until the server verifies tokens and error monitoring
is in place.

The Remote Config plugin activates fetched values before the SDK can validate
them. Consumers must read only the validated `ConfigSnapshot`, not the underlying
FlutterFire instance. App-facing snapshots preserve the last good value on errors.
