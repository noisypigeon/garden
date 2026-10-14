# pigeon.dev

Versioned, reusable templates, published at `pigeon.dev` and consumed by
[`noisypigeon/noisypigeon`](https://github.com/noisypigeon/noisypigeon)'s
`workloads/` (and any future infra repo). Two independently versioned tracks:

| Track | What it is | Tags |
| --- | --- | --- |
| [`templates/terraform/`](templates/terraform/) | 13 Terraform modules (Scaleway, Backblaze). See its [README](templates/terraform/README.md) for the module index. | `templates/terraform/<provider>/<module>/vX.Y.Z` |
| [`templates/zola-site/`](templates/zola-site/) | A reusable Zola theme. See its [README](templates/zola-site/README.md). | `templates/zola-site/vX.Y.Z` |

This repo holds template source only. It has no root provider/backend
configuration and is never `terraform`/`terragrunt` run standalone, and it
runs no infrastructure of its own.

## Consuming

A Terraform module is consumed by its short URL, which resolves through
Terraform/go-getter's HTTP module-source discovery protocol:

```hcl
module "state_bucket" {
  source = "https://pigeon.dev/modules/scaleway/object-bucket/v4.2.0"
}
```

Note the public namespace is `modules/...`, not `templates/terraform/...` —
it is a stable public interface, deliberately decoupled from this repo's
internal layout. See
[`templates/terraform/README.md`](templates/terraform/README.md) for the full
contract, including the equivalent hand-written `git::` form and how to
iterate locally against an unreleased change.

The theme is consumed by a Zola site fetching a clone of this repo and running
[`templates/zola-site/resolve-theme.sh`](templates/zola-site/resolve-theme.sh)
against it, driven by that site's own `[extra].theme_version`.

## Releasing

Every change ships through a labelled PR — the PR body becomes the changelog
entry and GitHub Release notes verbatim, and the `release:*` label drives the
version bump. See [`.claude/skills/release-pr/SKILL.md`](.claude/skills/release-pr/SKILL.md),
which is the discipline; `.github/workflows/template-release.yml` is the
automation that acts on it.

Every merged PR also adds one line to the root
[`CHANGELOG.md`](CHANGELOG.md) — `template-release.yml` for releases,
`root-changelog.yml` for everything else. Per-module and theme `CHANGELOG.md`
files carry the full, versioned entries.

## Decision records

This repo's ADRs live in [`adr/pigeon.dev/`](adr/pigeon.dev), as
`DEV-NNNN-<slug>.md`, and are written there — including future decisions about
these templates. [`adr/noisypigeon.com/`](adr/noisypigeon.com) is a sibling
domain holding the blog repo's own decisions, prefixed `NPC-`.

The split itself is
[ADR-0154](adr/pigeon.dev/DEV-0154-hoist-templates-to-pigeon-dev-repo.md); the
directly relevant history is ADR-0037 (the original `pigeon-tf` merge), ADR-0093
and ADR-0110 (prior relocations), ADR-0109/0136 (the short-URL mechanism), and
ADR-0112/0113/0114/0139 (the theme). The corpus itself moved here in
[ADR-0157](adr/pigeon.dev/DEV-0157-hoist-adrs-to-pigeon-dev.md) and took its
current name and `DEV-` prefix in
[DEV-0160](adr/pigeon.dev/DEV-0160-rename-adr-domain-to-pigeon-dev-and-root-changelog-contract.md),
which also set the root-changelog contract below. Bare `ADR-NNNN` in older prose
and `DEV-NNNN` refer to the same records.
