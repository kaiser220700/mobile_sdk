/// Concise public names; legacy names remain available for migration.
library;

import "remote_config.dart" as impl;

/// Public name for [impl.MobileRemoteConfigSettings].
typedef Settings = impl.MobileRemoteConfigSettings;

/// Public name for [impl.MobileRemoteConfigSource].
typedef Source = impl.MobileRemoteConfigSource;

/// Public name for [impl.RemoteConfigTransport].
typedef Transport = impl.RemoteConfigTransport;

/// Public name for [impl.FirebaseRemoteConfigTransport].
typedef FirebaseTransport = impl.FirebaseRemoteConfigTransport;

/// Public name for [impl.InMemoryRemoteConfigTransport].
typedef InMemoryTransport = impl.InMemoryRemoteConfigTransport;
