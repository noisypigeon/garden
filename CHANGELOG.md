# Changelog

One line per PR across this whole repo, sectioned by date, newest first. Every
merged PR gets exactly one line here; a PR that changes a releasable unit
additionally gets its full PR body in that unit's own `CHANGELOG.md`. PD-0160 is
the contract.

Not versioned — for versioned, package-scoped changelogs see
`templates/terraform/*/*/CHANGELOG.md` (each Terraform module) and
[`templates/zola-site/CHANGELOG.md`](templates/zola-site/CHANGELOG.md) (the
theme, versioned since ADR-0113).

Entry format is `- [<tag>] <PR title> ([#N](pr-url))`, where `<tag>` is one of:

- `<provider>/<module>` — a released Terraform module
- `zola-site` — a released theme version
- `pigeon.dev` — the Zola site under `pigeon.dev/`
- `templates` — a `templates/` change that releases nothing (e.g. a README)
- `adr` — decision records under `adr/`
- `ci` — `.github/` workflows and scripts
- `repo` — anything else (root docs, `.mise.toml`, tooling)

The first two are written by `template-release.yml` as part of tagging a
release; the rest by `root-changelog.yml`, which runs on every merged PR and
stands down when `template-release.yml` owns the entry. Both go through
`.github/scripts/root-changelog.sh`, which inserts below the marker at the end
of this header — keep that line where it is.

This file starts at this repo's own beginning. Entries predating
[ADR-0154](adr/pigeon.dev/PD-0154-hoist-templates-to-pigeon-dev-repo.md), which
moved `templates/` here out of `noisypigeon/noisypigeon`, stayed in that repo's
root `CHANGELOG.md` rather than being untangled from it — the same call ADR-0084
made when `pigeon-cli` split out. Each module's own `CHANGELOG.md` travelled
with the module, so no per-module history was lost.

<!-- entries below; newest first -->

## 2026-10-13

- [templates] Backfill changelog entries for six undocumented module tags ([#14](https://github.com/noisypigeon/pigeon.dev/pull/14))
- [adr] Open the adr/pigeon-lib ADR domain and record the hub-and-spoke repo architecture ([#13](https://github.com/noisypigeon/pigeon.dev/pull/13))
- [adr] Rename the ADR domain to adr/pigeon.dev with PD- IDs, and make the root changelog a contract ([#12](https://github.com/noisypigeon/pigeon.dev/pull/12))
