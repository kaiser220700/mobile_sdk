import "mobile_update_config.dart";

enum MobileUpdateRequirement { none, soft, force }

class MobileUpdateDecision {
  const MobileUpdateDecision(this.requirement);

  const MobileUpdateDecision.none() : requirement = MobileUpdateRequirement.none;

  final MobileUpdateRequirement requirement;

  bool get shouldPrompt => requirement != MobileUpdateRequirement.none;

  bool get isForced => requirement == MobileUpdateRequirement.force;
}

/// Compares semantic versions in the `major.minor.patch` format and decides
/// whether the host app should show a soft or mandatory update prompt.
class MobileUpdatePolicy {
  const MobileUpdatePolicy();

  MobileUpdateDecision evaluate({required String currentVersion, required MobileUpdateConfig config}) {
    if (!config.enabled) return const MobileUpdateDecision.none();

    final current = MobileVersion.tryParse(currentVersion);
    if (current == null) return const MobileUpdateDecision.none();

    final minimum = MobileVersion.tryParse(config.minVersion);
    if (minimum != null && current.compareTo(minimum) < 0) {
      return const MobileUpdateDecision(MobileUpdateRequirement.force);
    }

    final latest = MobileVersion.tryParse(config.latestVersion);
    if (latest != null && current.compareTo(latest) < 0) {
      return const MobileUpdateDecision(MobileUpdateRequirement.soft);
    }

    return const MobileUpdateDecision.none();
  }
}

/// Numeric `major.minor.patch` version used by the update policy.
class MobileVersion implements Comparable<MobileVersion> {
  const MobileVersion(this.major, this.minor, this.patch);

  static MobileVersion? tryParse(String value) {
    final segments = value.split(".");
    if (segments.isEmpty || segments.length > 3) return null;

    final parts = <int>[0, 0, 0];
    for (var index = 0; index < segments.length; index++) {
      final parsed = int.tryParse(segments[index]);
      if (parsed == null) return null;
      parts[index] = parsed;
    }
    return MobileVersion(parts[0], parts[1], parts[2]);
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(MobileVersion other) {
    final majorComparison = major.compareTo(other.major);
    if (majorComparison != 0) return majorComparison;

    final minorComparison = minor.compareTo(other.minor);
    if (minorComparison != 0) return minorComparison;

    return patch.compareTo(other.patch);
  }
}
