# Independent package releases

Versioning is per package. main/develop may contain different package versions
and a mixture of prerelease/stable packages. There is no mandatory shared
version or automatic mass bump.

The package catalog defines group/stage; pubspec.yaml is the source of truth
for each version. Package changelogs describe changes. The root changelog is
a cross-package summary, not the authority for one global release version.

## Prepare one package

1. Confirm its public responsibility and required consumer validation.
2. Change only the affected package version. Bump dependent packages only when
   their implementation/API/constraints change; a shared repo is not a reason.
3. Add dated notes for the exact version. Development versions can use an
   Unreleased section until a release is prepared.
4. Resolve dependencies and refresh changed path lockfiles.
5. Run `./tool/verify_workspace.sh` and relevant native/consumer checks.
6. Validate the release ref, for example:

```sh
./tool/verify_release_metadata.sh release/mobile_ui_kit/1.0.0-rc.1
```

The guard checks all package metadata, but only the selected package must
match this release version and dated heading. It never aligns unrelated
package versions. Workspace-wide release/X.Y.Z refs are retired.

## Publish after review/merge

Tag the intended commit with `<package>/v<version>`. For example, once the
UI candidate is approved and merged:

```sh
git tag -a mobile_ui_kit/v1.0.0-rc.1 -m "mobile_ui_kit 1.0.0-rc.1"
git push origin mobile_ui_kit/v1.0.0-rc.1
```

A package tag points to the entire repository snapshot; relative path
dependencies still come from that checkout. For graphs sharing internal
dependencies, pick compatible common snapshots. See
[organization](package-organization.md#git-distribution-constraints).

Do not move existing tags. Legacy v0.x tags continue to identify their
original snapshots. Keep tags already consumed by apps for resolution/rollback.
Creating a GitHub Release page is optional and independent of keeping a tag.

After release, increment only packages entering new development. No immediate
workspace-wide next-major bump is required.

## Stability

A candidate is not stable simply because its tests pass. Its owner must
confirm scope/support and relevant consumer validation before promoting it.
For a package at stable 1.x, incompatible public changes require a new major
version. Deprecated aliases still form part of the supported public surface
until that major migration. Experimental packages are explicitly marked 0.x.

## CI and checks

Release metadata is checked on main, develop, release/** and package tags.
Policy tests cover mixed versions, isolated release selection, invalid names,
maturity rules, changelog requirements and malformed release refs.
The workspace command also checks graph boundaries and all Dart/Flutter tests.

## Distribution

Git remains the distribution channel; publish_to: none stays in place.
Pub.dev publication is separate: establish license/publisher ownership,
package names, hosted dependencies and publish dry-runs first.

Rollback a consumer by restoring its previous app commit, SDK revision and
lockfile, resolving dependencies and rebuilding its own flavor. Do not move
a published tag to simulate rollback.
