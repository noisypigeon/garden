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

**This repo cuts no releases.** Since DEV-0162 it holds content and its own
deploy, and every versioned, reusable asset — the Terraform modules, the Zola
theme, the shared CI — lives in
[`noisypigeon/pigeon-lib`](https://github.com/noisypigeon/pigeon-lib), which is
where a release PR and its `release:*` label belong. [`.lib-version`](.lib-version)
pins the version this repo consumes, and [`fetch-lib.sh`](fetch-lib.sh)
materializes it.

Every merged PR still gets exactly one line in the root
[`CHANGELOG.md`](CHANGELOG.md) — `root-changelog.yml` writes it, for every PR
without exception, running `root-changelog.sh` out of the pinned library rather
than a vendored copy. DEV-0160 is that contract; DEV-0162 is what left this
workflow as the only writer of it.

## Decision records

This repo's ADRs live in [`adr/`](adr), as `DEV-NNNN-<slug>.md`, and are
written there. Each repo now keeps its own corpus under its own prefix —
`noisypigeon.com` holds `NPC-` records, `pigeon-lib` holds `LIB-` ones — so this
directory is `DEV-` only, and flat.

The split itself is
[ADR-0154](adr/DEV-0154-hoist-templates-to-pigeon-dev-repo.md); the
directly relevant history is ADR-0037 (the original `pigeon-tf` merge), ADR-0093
and ADR-0110 (prior relocations), ADR-0109/0136 (the short-URL mechanism), and
ADR-0112/0113/0114/0139 (the theme). The corpus itself moved here in
[ADR-0157](adr/DEV-0157-hoist-adrs-to-pigeon-dev.md) and took its
current name and `DEV-` prefix in
[DEV-0160](adr/DEV-0160-rename-adr-domain-to-pigeon-dev-and-root-changelog-contract.md),
which also set the root-changelog contract above, and was flattened to `adr/` by
[DEV-0161](adr/DEV-0161-flatten-the-adr-corpus-and-re-prefix-to-dev.md). Bare
`ADR-NNNN` in older prose and `DEV-NNNN` refer to the same records.
