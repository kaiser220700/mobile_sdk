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
package versions. New workspace-wide release/X.Y.Z refs are rejected.

The existing `release/0.7.0` branch is explicitly allowed as an integration
branch for the current GitHub-only work. On this branch the guard validates
every package's name, version, stage and changelog, as it does on main/develop;
it does not require all packages to be 0.7.0 or to have dated release notes.
This exception does not allow a new global `v0.7.0` tag, arbitrary workspace
release branches, or skipping checks. Package release refs still require their
own exact version and dated notes.

## Independent hotfixes

Create a hotfix from the intended main snapshot and backport only its required
fixes and regression coverage. Merge that hotfix directly to main independently
of integration branches, then forward-port it so a later integration merge does
not undo the fixes. Do not merge a feature batch just to distribute a hotfix.

The current UI fix uses `hotfix/mobile-ui-kit-rc3`, based on local main
`18ec3ed`, and package version `1.0.0-rc.3`. This avoids reusing rc.2 from the
integration branch. Candidate maturity and existing validation requirements
still apply; calling it a hotfix does not establish a device-test pass or stable
promotion. No test/build or remote publication is implied by source preparation.

## Optional GitHub tags after review/merge

Consumers can pin an approved full Git revision without publishing a package.
To record a release within GitHub, optionally tag the intended commit with
`<package>/v<version>`. For example, once the
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
For the current 0.7.x integration snapshot, the owner explicitly waived
external-app pilot testing on 2026-11-16. Repository checks and the web build
are the completion criteria for this snapshot. This is not a consumer-test
pass or a stable promotion; package stages remain unchanged. Native milestones
retain the separate validation requirements in the native PLAN.
For a package at stable 1.x, incompatible public changes require a new major
version. Deprecated aliases still form part of the supported public surface
until that major migration. Experimental packages are explicitly marked 0.x.

## CI and checks

Release metadata is checked on main, develop, release/** and package tags.
The workspace and portal build workflow also runs on pushes to main, develop
and release/**, as well as pull requests and package tags.
Policy tests cover mixed versions, isolated release selection, invalid names,
maturity rules, changelog requirements and malformed release refs.
The workspace command also checks graph boundaries and all Dart/Flutter tests.

## Distribution

GitHub is the only source distribution channel. `publish_to: none` stays in
place. Publishing to pub.dev or another hosted package registry is not planned
and is not a requirement for using or completing this SDK.

Apps resolve packages through authorized GitHub access and pin a full commit
revision or an existing package tag. Optional GitHub tags/releases document
snapshots; they do not upload packages to a registry. Consumer validation and
rollback still matter when no package is published.

GitHub repository access and permission to reuse the source are separate
decisions. KAISER reserves rights in the covered original materials under
[LICENSE](../LICENSE) and [COPYRIGHT](../COPYRIGHT.md). Project authorization
follows the [source usage policy](source-usage-policy.md); access alone is not
an open-source license. Third-party dependencies retain their own licenses and
notices.

Rollback a consumer by restoring its previous app commit, SDK revision and
lockfile, resolving dependencies and rebuilding its own flavor. Do not move
a published tag to simulate rollback.
