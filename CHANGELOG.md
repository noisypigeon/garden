# Changelog

One line per PR across this whole repo, sectioned by date, newest first. Every
merged PR gets exactly one line here; a PR that changes a releasable unit
additionally gets its full PR body in that unit's own `CHANGELOG.md`. DEV-0160 is
the contract.

Not versioned, and since DEV-0162 nothing in this repo is: the versioned,
package-scoped changelogs moved to `noisypigeon/pigeon-lib` along with the
Terraform modules and the Zola theme they describe.

Entry format is `- [<tag>] <PR title> ([#N](pr-url))`, where `<tag>` is one of:

- `pigeon.dev` — the Zola site under `web/` (`pigeon.dev/src/` before DEV-0162)
- `adr` — decision records under `adr/`
- `ci` — `.github/` workflows and scripts
- `repo` — anything else (root docs, `.mise.toml`, tooling)

All of them are written by `root-changelog.yml`, which runs on every merged PR
with no exceptions. It calls `root-changelog.sh` out of the pinned library
rather than a vendored copy, and that script inserts below the marker at the end
of this header — keep that line where it is.

Two older tags appear in entries below but are no longer issued. `templates`
marked a `templates/` change that released nothing; DEV-0162 moved that
directory to `pigeon-lib`. A `<provider>/<module>` or `zola-site` tag would have
marked a release, written by `template-release.yml` — none ever were, since this
repo's releases all predate DEV-0160's contract and DEV-0162 moved the releasing
itself to `pigeon-lib` before the case arose.

This file starts at this repo's own beginning. Entries predating
[ADR-0154](adr/DEV-0154-hoist-templates-to-pigeon-dev-repo.md), which
moved `templates/` here out of `noisypigeon/noisypigeon`, stayed in that repo's
root `CHANGELOG.md` rather than being untangled from it — the same call ADR-0084
made when `pigeon-cli` split out. Each module's own `CHANGELOG.md` travelled
with the module, so no per-module history was lost.

<!-- entries below; newest first -->

## 2026-10-16

- [adr] docs(adr): DEV-0165 pigeon.dev becomes noisypigeon.garden ([#38](https://github.com/noisypigeon/pigeon.dev/pull/38))
- [terraform] feat(terraform): turn the Scaleway provider off and drop its secrets (DEV-0164) ([#37](https://github.com/noisypigeon/pigeon.dev/pull/37))
- [terraform] chore(terraform): destroy this domain's Scaleway project ([#36](https://github.com/noisypigeon/pigeon.dev/pull/36))
- [terraform] chore(terraform): destroy the old Scaleway state bucket ([#35](https://github.com/noisypigeon/pigeon.dev/pull/35))
- [terraform] chore(terraform): let the old Scaleway state bucket be destroyed with its contents ([#34](https://github.com/noisypigeon/pigeon.dev/pull/34))
- [terraform] feat(terraform): move this domain's Terraform state to Cloudflare R2, backed up to B2 (DEV-0164) ([#33](https://github.com/noisypigeon/pigeon.dev/pull/33))
- [terraform] feat(terraform): add the R2 state bucket and its B2 backup (DEV-0164) ([#32](https://github.com/noisypigeon/pigeon.dev/pull/32))
- [ci] ci: pin pigeon-lib's reusable workflows at workflows/v1.5.3 ([#31](https://github.com/noisypigeon/pigeon.dev/pull/31))

## 2026-10-15

- [terraform] chore(terraform): take root.hcl v2.0.0, with providers named in spoke.hcl ([#30](https://github.com/noisypigeon/pigeon.dev/pull/30))
- [terraform] refactor(terraform): rename the leaves to LIB-0004's layout ([#29](https://github.com/noisypigeon/pigeon.dev/pull/29))
- [terraform] refactor(terraform): move the DNS leaves onto cloudflare/dns-record ([#28](https://github.com/noisypigeon/pigeon.dev/pull/28))
- [repo] docs: list willowgraysen.com's RUN- ADR domain ([#27](https://github.com/noisypigeon/pigeon.dev/pull/27))
- [terraform] fix(terraform): point the state bucket output at terraform/secrets.enc ([#26](https://github.com/noisypigeon/pigeon.dev/pull/26))
- [terraform] feat(dev-0163)!: run pigeon.dev's Terraform from this repo ([#25](https://github.com/noisypigeon/pigeon.dev/pull/25))
- [ci] Call pigeon-lib's reusable root-changelog workflow ([#24](https://github.com/noisypigeon/pigeon.dev/pull/24))
- [repo] docs: name noisypigeon.com's ADR prefix as COM- ([#23](https://github.com/noisypigeon/pigeon.dev/pull/23))
- [ci] Pin pigeon-lib at workflows/v1.0.7 ([#22](https://github.com/noisypigeon/pigeon.dev/pull/22))
- [pigeon.dev] Rename the site root to web/ and file DEV-0162 ([#21](https://github.com/noisypigeon/pigeon.dev/pull/21))
- [pigeon.dev] Remove the hoisted templates ([#20](https://github.com/noisypigeon/pigeon.dev/pull/20))
- [ci] Retire the local release automation ([#19](https://github.com/noisypigeon/pigeon.dev/pull/19))

## 2026-10-14

- [pigeon.dev] Consume pigeon-lib at a pinned version ([#18](https://github.com/noisypigeon/pigeon.dev/pull/18))
- [pigeon.dev] Flatten the ADR corpus to adr/ and re-prefix it DEV- ([#17](https://github.com/noisypigeon/pigeon.dev/pull/17))

## 2026-10-13

- [pigeon.dev] Drop the legacy modules/* tag arm from the redirect generator ([#16](https://github.com/noisypigeon/pigeon.dev/pull/16))
- [templates] Correct the seed-tag entries' GitHub Release claim ([#15](https://github.com/noisypigeon/pigeon.dev/pull/15))
- [templates] Backfill changelog entries for six undocumented module tags ([#14](https://github.com/noisypigeon/pigeon.dev/pull/14))
- [adr] Open the adr/pigeon-lib ADR domain and record the hub-and-spoke repo architecture ([#13](https://github.com/noisypigeon/pigeon.dev/pull/13))
- [adr] Rename the ADR domain to adr/pigeon.dev with DEV- IDs, and make the root changelog a contract ([#12](https://github.com/noisypigeon/pigeon.dev/pull/12))
