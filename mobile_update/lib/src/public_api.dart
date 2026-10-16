/// Concise public names; legacy names remain available for migration.
library;

import "mobile_update_checker.dart" as impl;
import "mobile_update_config.dart" as impl;
import "mobile_update_policy.dart" as impl;

/// Public name for [impl.MobileUpdateConfigSource].
typedef UpdateConfigSource = impl.MobileUpdateConfigSource;

/// Public name for [impl.MobileAppVersionLoader].
typedef AppVersionLoader = impl.MobileAppVersionLoader;

/// Public name for [impl.MobileUpdateCheckResult].
typedef UpdateCheckResult = impl.MobileUpdateCheckResult;

/// Public name for [impl.MobileUpdateChecker].
typedef UpdateChecker = impl.MobileUpdateChecker;

/// Public name for [impl.MobileUpdateConfig].
typedef UpdateConfig = impl.MobileUpdateConfig;

/// Public name for [impl.MobileUpdateRequirement].
typedef UpdateRequirement = impl.MobileUpdateRequirement;

/// Public name for [impl.MobileUpdateDecision].
typedef UpdateDecision = impl.MobileUpdateDecision;

/// Public name for [impl.MobileUpdatePolicy].
typedef UpdatePolicy = impl.MobileUpdatePolicy;

/// Public name for [impl.MobileVersion].
typedef AppVersion = impl.MobileVersion;
