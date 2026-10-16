# Migration to 1.0.0

> Historical migration notes for the unpublished global 1.0.0 preparation.
> Names and DevTool composition notes below remain useful, but the shared
> version/scope proposal is superseded by [independent package organization](package-organization.md).


## Stable scope

App wiring, UI primitives, typed config/telemetry contracts, update policy,
Firebase lifecycle/Remote Config adapters and DevTool logging/menu APIs are the
1.0.0 scope. Stable packages share version 1.0.0. Existing public compatibility
names remain supported throughout 1.x; removing or changing their contracts
requires a major release. Additions use minor releases; compatible fixes use
patch releases.

See [module name mapping](sdk-api-naming.md) and [UI mapping](ui-api-naming.md).
The concise names are type aliases, with the same type identity and behavior.
Constructor/factory/static access and interface implementations remain usable.
Use module import aliases; new names can collide with Flutter/provider classes.

SDK-owned UI may re-export selected pull_to_refresh_flutter3 controllers and
indicator types. These are part of the supported 1.x surface. A dependency
change that breaks those public types also requires a major SDK release.

## Production integration

1. Pin all Git-based SDK dependencies to the same release tag or full revision.
   Use `path: mobile_sdk` within the Git dependency for the umbrella.
2. Use `as sdk` for app/core/update APIs and `as ui` for UI APIs, or import the
   individual packages. Do not import developer tools in production.
3. Rename UI references using the mapping. `ui.Button(child: ...)` is additive;
   the string `label` and named constructors still work.
4. Replace `MobileDevToolRefreshLoadMore` with `ui.RefreshView` and use the UI
   package for refresh controllers/configuration. Remove the DevTool dependency,
   development imports/wrappers and configuration assets from production source.
5. Run consumer analysis/tests and build its real Prod flavor. A hidden launcher
   is not a source/dependency boundary. Station-app must also pass its own
   no-DevTool gate; its pinned revision is not changed by this SDK release.

## Optional tools: breaking DevTool composition change

DevTool 1.0.0 no longer automatically mounts Screen Draw or Fuzz Tap.
`ToolsOverlay` owns the launcher/menu only. Its former `currentRouteKey` and
`scrollDelta` constructor parameters are removed; those signals belong to the
host's tool composition. No production package depends on the extracted tools.

`mobile_fuzz` and `mobile_screen_draw` are experimental version 0.1.0, outside
the stable 1.x contract. Opt into either independently in non-production builds.
Use `Configuration.quickActions` / `panels` and compose tool overlays in the
host. See `example/lib/developer_tools.dart` for complete working wiring:
lifecycle/disposal, launcher visibility, exclusion from random taps, action
registration, network failure mapping and log history.

- `fuzz.Runner` accepts an optional `networkFailures` snapshot reader. It does
  not import DevTool. IDs must be stable; only errors appearing after session
  start terminate that run. Host reader failures terminate the session safely.
- `draw.Controller` owns route-aware annotation state. Forward route identity
  with `updateRoute`; forward scroll deltas with `addScrollDelta` while drawing
  is open if annotations should follow content. Dispose it with its owner.
- Keep tool dependencies out of production. Fuzz uses Semantics activation,
  not real gesture input or native picker automation, and does not replace E2E.

## Rollback

Restore the consumer's previous SDK Git revision and lockfile, then resolve
dependencies and rebuild the same flavor. For source migration rollback,
restore the matching application commit as well. Do not move an existing tag.
A regression after publishing receives a new patch/minor version as appropriate.
