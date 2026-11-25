# Package organization and compatibility

## Scope

This repository is a collection of shared Flutter libraries, service adapters
and developer tools. It does not prescribe an application architecture or
require every app to install a platform-sized SDK.

Keep current root-level directories. Moving everything to packages/ would
change Git dependency paths without improving the consumer's API or graph.

## Application libraries

- mobile_ui_kit owns reusable visual components, interactions and accessibility.
  The current hotfix source candidate is 1.0.0-rc.3, not a published stable 1.0.0.
- mobile_sdk_core owns typed configuration and telemetry contracts/fakes.
  Add it when the app needs those contracts; UI does not depend on it.
- mobile_update makes update decisions and coordinates host-supplied loaders.
  It does not choose a backend, show dialogs or launch a store.

## Service adapters

Firebase lifecycle and Remote Config are explicit adapters. An app that does
not use them should not resolve native Firebase plugins. The host still owns
project initialization, credentials, policy and consent.

## Developer tools

DevTool provides logging, a launcher and generic tool registration.
Fuzz/Screen Draw are independent opt-in tools composed by the host. None
belongs in a production dependency graph or business screen implementation.

## App composition and the umbrella

mobile_app_base currently contains AppConfig/AppEnvironment and an AppShell
that wires MaterialApp, a home widget, navigator and theme. It is an optional
convenience, not a required architecture or a production foundation.

The recommended UI-only path is Flutter MaterialApp + mobile_ui_kit.
The production example enforces a resolved graph without mobile_sdk,
mobile_app_base, core, update, Firebase or developer tools.

The existing mobile_sdk umbrella retains its app/core/UI/update dependencies
and exports. Keeping AppShell here is a deliberate compatibility decision.
A new barrel alone would not remove a pubspec dependency, so no misleading
"lightweight umbrella" entrypoint is introduced.

If a future major release removes app composition from the umbrella, it must
include a separate consumer migration. This organization change does not
remove or rename any existing public entrypoint.

## Versions and stability

The package catalog records group and maturity; each pubspec owns its version.
UI is a release candidate; the other packages remain development/experimental.
The previous unpublished workspace-wide 1.0.0 preparation is superseded.

- Tests passing establishes technical evidence, not automatic product maturity.
- A package can reach 1.0.0 only when its public scope, real consumer needs,
  migration path, owner/support expectations and relevant integration are clear.
- Other packages do not need version bumps when an unrelated package releases.
- Compatibility names remain available. Existing DevTool extraction changes
  from the prior preparation are still documented separately; this does not
  claim upgrading from every historical tag requires no source migration.
- Existing consumers pinned to Git revisions do not update automatically.
  No application outside this repository is changed by this organization work.

## Git distribution constraints

Use package-scoped tags, such as mobile_ui_kit/v1.0.0-rc.1.
Each tag still identifies a complete repository snapshot. Relative path
dependencies resolve inside that checkout; independent package versions do
not guarantee arbitrary snapshots can be mixed in one dependency graph.
For packages sharing transitive path dependencies, use a compatible common
revision/snapshot and inspect the resolved graph.

Old v0.x tags remain valid and are not moved or deleted. GitHub Releases can
be created only for intentionally distributed versions; not every commit/tag
needs a Release page. Public registry publication remains separate work.

See [release workflow](release-workflow.md) and
[current verification record](organization-validation.md).
