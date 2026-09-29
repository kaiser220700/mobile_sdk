# mobile_sdk_firebase_core

Lifecycle for host-selected Firebase adapters. The host initializes Firebase
for its flavor, then calls `MobileFirebase.initialize` with the selected module
set and matching adapters. This package imports only `firebase_core`, so apps
using one adapter do not pull in all Firebase plugins. Dispose the returned
runtime during shutdown or test teardown.
