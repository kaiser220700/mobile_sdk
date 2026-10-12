# Release workflow

All SDK packages share one version. `main` contains only stable releases;
`develop` contains the next pre-release; a short-lived `release/X.Y.Z` branch
is used for final validation and release notes.

| Branch | Version format | Purpose |
|---|---|---|
| `main` | `X.Y.Z` | Released SDK; root changelog must contain `X.Y.Z`. |
| `develop` | `X.Y.Z-dev.N` | Ongoing work for the next release. |
| `release/X.Y.Z` | `X.Y.Z` | Stabilization, changelog completion, and release verification. |

## Starting the next release

After tagging the stable release on `main`, create `develop`, set every SDK
package to its next development version, refresh path lockfiles, and push it:

```bash
git switch main
git switch -c develop
# Set all SDK package versions to the next X.Y.Z-dev.0 version.
./tool/verify_workspace.sh
git add -A
git commit -m "chore: start X.Y.Z development"
git push -u origin develop
```

Increment `dev.N` only when a separately distributed development build needs a
new identity. Feature branches merge into `develop`; they do not change the
shared version by themselves.

## Cutting a release

```bash
git switch develop
git pull --ff-only
git switch -c release/X.Y.Z
# Replace X.Y.Z-dev.N with X.Y.Z in every SDK package and refresh lockfiles.
# Add the root and package release notes.
./tool/verify_workspace.sh
./tool/verify_release_metadata.sh release/X.Y.Z
git add -A
git commit -m "chore: prepare mobile SDK vX.Y.Z"
git push -u origin release/X.Y.Z
```

Open a pull request from `release/X.Y.Z` to `main`. After it is merged, tag
the resulting `main` commit and publish the tag:

```bash
git switch main
git pull --ff-only
git tag -a vX.Y.Z -m "mobile SDK vX.Y.Z"
git push origin vX.Y.Z
```

Then merge `main` back into `develop` and advance `develop` to the next
`-dev.0` version.

## CI guard

`.github/workflows/release-metadata.yml` runs
`tool/verify_release_metadata.sh` on `main`, `develop`, and `release/**`.
It requires all SDK packages to share a version, enforces each branch's version
format, and requires a root changelog heading for stable/release branches.
