# pigeon.dev

The Zola site published at `pigeon.dev`, and the short-URL host that resolves
Terraform module sources to the repo holding them.

**The templates themselves are no longer here.** DEV-0162 moved
`templates/terraform/` and `templates/zola-site/` to
[`noisypigeon/pigeon-lib`](https://github.com/noisypigeon/pigeon-lib), where
they live as `terraform/` and `zola-site/` and are tagged and released. This
repo kept the one thing that must stay: `pigeon.dev/modules/...` is a public
interface with a stability guarantee, and serving it is a property of the
domain, not of the code.

So this repo is content, its own deploy, and — since DEV-0163 — the Terraform
that serves the domain: DNS for the site and the wiki, the Fastmail records, the
Scaleway project, and its own state bucket, under [`terraform/`](terraform). It
holds no templates and no scripts beyond [`fetch-lib.sh`](fetch-lib.sh); its
[`root.hcl`](root.hcl) is generated from `pigeon-lib`'s template at the version
[`spoke.hcl`](spoke.hcl) pins, and committed. One leaf deliberately stayed
behind: `state/iam`, which mints this domain's deploy key, still runs from
`noisypigeon/noisypigeon` (LIB-0001 §8, DEV-0163).

## Consuming

A Terraform module is consumed by its short URL, unchanged by the move, which
resolves through Terraform/go-getter's HTTP module-source discovery protocol:

```hcl
module "state_bucket" {
  source = "https://pigeon.dev/modules/scaleway/object-bucket/v4.2.0"
}
```

The public namespace is `modules/...` — deliberately decoupled from wherever
the source actually lives, which is exactly what let the source move out from
under it without breaking a single pin. See
[`pigeon-lib`'s `terraform/README.md`](https://github.com/noisypigeon/pigeon-lib/blob/main/terraform/README.md)
for the full contract, including the equivalent hand-written `git::` form and
how to iterate locally against an unreleased change.

The theme is consumed the same way: a Zola site pins a version and runs
`zola-site/resolve-theme.sh` out of a `pigeon-lib` checkout. This site does it
through [`fetch-lib.sh`](fetch-lib.sh) and [`.lib-version`](.lib-version).

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
`noisypigeon.com` holds `COM-` records (formerly `NPC-`), `pigeon-lib` holds `LIB-` ones,
`willowgraysen.com` holds `RUN-` ones — so this
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
