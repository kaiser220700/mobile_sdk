# mobile_app_base

Shared app-host wiring used by both SDK examples in this repository.

The package owns only composition concerns:

- `AppConfig`: environment and host capabilities.
- `MobileAppShell`: `MaterialApp`, theme and root navigator wiring.

Business features, routing policy, authentication, storage and remote config
remain owned by the consuming app.
