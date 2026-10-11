# CLAUDE.md

This repo holds `templates/` — versioned, reusable templates published at
`pigeon.dev`, hoisted out of `noisypigeon/noisypigeon` by ADR-0154 (which kept
the `templates/…` paths byte-identical, so every pre-existing tag prefix,
workflow glob and short URL kept working unchanged). Two independently
versioned tracks:

- `templates/terraform/<provider>/<module>/` — 13 Terraform modules (Scaleway,
  Backblaze), tagged `templates/terraform/<provider>/<module>/vX.Y.Z`, each
  self-contained (own `versions.tf`, `README.md`, `CHANGELOG.md`). Consumed via
  short `pigeon.dev/modules/<provider>/<module>/vX.Y.Z` URLs that resolve
  through go-getter's HTTP discovery protocol to a `git::` source against this
  repo. The public URL path is `modules/…`, **not** `templates/terraform/…` —
  that namespace is a stable public interface, deliberately decoupled from
  internal layout (ADR-0109/0110) and now from which repo the tag lives in.
- `templates/zola-site/` — a reusable Zola theme, tagged
  `templates/zola-site/vX.Y.Z`, consumed by a site setting
  `[extra].theme_version` and running `resolve-theme.sh` out of a clone of this
  repo. The script resolves everything relative to its own location, so it
  works wherever the clone lands.

See `README.md` for the consumption contract and `templates/terraform/README.md`
for the module index.

## Where the decisions live

**This repo has no `docs/adr/`.** Its ADRs — including future decisions about
these templates — live in
[`noisypigeon/noisypigeon/docs/adr/`](https://github.com/noisypigeon/noisypigeon/tree/main/docs/adr),
which remains the decision-record home for both repos. Before making an
architectural or interface change here, read the relevant ADRs there and keep
new work consistent with them; if a change would contradict one, flag it rather
than silently diverging, and prefer writing a new ADR there over undocumented
drift.

The load-bearing ones for this repo: ADR-0154 (the split, and the prefix→repo
mapping that keeps 20 legacy `modules/*`-era tags resolving against
`noisypigeon/noisypigeon` — one of them is still live-pinned), ADR-0037/0093/0110
(this directory's prior homes and why old tags still resolve), ADR-0109/0136
(the short-URL redirect mechanism and its move to the `pigeon.dev` host),
ADR-0119/0120/0153 (the modules' current composition shape), and
ADR-0112/0113/0114/0139 (the theme, its versioning, and its resolution).

## Dev cycle

Every change ships through a labelled PR — see the `release-pr` skill, which is
the discipline, not just a convenience. The PR body becomes the changed unit's
`CHANGELOG.md` entry and GitHub Release notes **verbatim**, and exactly one
`release:*` label drives the version bump. There is no human reviewer and no
branch protection.

On merge, `template-release.yml` tags each changed module (or the theme),
updates its `CHANGELOG.md` and the root one, cuts a GitHub Release, and then
dispatches a site deploy **in `noisypigeon/noisypigeon`** — that's where
`pigeon.dev`'s Zola site lives, and it generates each version's redirect page
and release post from this repo's tags and `CHANGELOG.md` files. That dispatch
needs `BOT_GITHUB_TOKEN` to carry `actions: write` on that repo; if it fails,
the version is tagged here but its short URL 404s there. `module-docs.yml`
separately regenerates each module's input/output table on any `.tf` change.

A change spanning a module and its consumer is two PRs in two repos: this one
merges, tags and deploys first, then the consumer's `source =` pin is bumped in
`noisypigeon/noisypigeon`. For local iteration before tagging, a consumer can
point `source =` at a relative path into a sibling clone of this repo instead.

## Commands

- `mise run fmt-terraform` / `mise run fmt-check-terraform` — format / check
  formatting for Terraform files.
