# Changelog

One line per PR across this whole repo, sectioned by date, newest first.
Not versioned — for versioned, package-scoped changelogs see
`templates/terraform/*/*/CHANGELOG.md` (each Terraform module) and
[`templates/zola-site/CHANGELOG.md`](templates/zola-site/CHANGELOG.md) (the
theme, versioned since ADR-0113). Entry format:
`- [<provider>/<module>] <PR title> ([#N](pr-url))`, written automatically by
`template-release.yml` on merge.

This file starts at this repo's own beginning. Entries predating
[ADR-0154](https://github.com/noisypigeon/noisypigeon/blob/main/docs/adr/0154-hoist-templates-to-pigeon-dev-repo.md),
which moved `templates/` here out of `noisypigeon/noisypigeon`, stayed in that
repo's root `CHANGELOG.md` rather than being untangled from it — the same call
ADR-0084 made when `pigeon-cli` split out. Each module's own `CHANGELOG.md`
travelled with the module, so no per-module history was lost.
