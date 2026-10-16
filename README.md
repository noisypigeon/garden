# garden

The Zola site published at [`noisypigeon.garden`](https://noisypigeon.garden),
and the short-URL host that resolves Terraform module sources to the repo
holding them
([LIB-0009](https://github.com/noisypigeon/pigeon-lib/blob/main/docs/adr/LIB-0009-terraform-short-urls-move-to-noisypigeon-garden.md)).

**The modules and theme themselves aren't here.** They live in
[`noisypigeon/pigeon-lib`](https://github.com/noisypigeon/pigeon-lib) as
`terraform/` and `zola-site/`, where they are tagged and released. What
this repo keeps is the thing a domain has to serve: the public
`noisypigeon.garden/terraform/...` interface.

So this repo is content, its own deploy, and the Terraform that serves the
domain under [`terraform/`](terraform):

- the `noisypigeon.garden` DNS for GitHub Pages;
- its own Terraform state bucket on Cloudflare R2, with a Backblaze B2 backup
  (DEV-0164).

This repo holds no templates and no scripts beyond [`fetch-lib.sh`](fetch-lib.sh).
Its [`root.hcl`](root.hcl) is generated from `pigeon-lib`'s template at the
version [`spoke.hcl`](spoke.hcl) pins, and committed.

## Consuming

A Terraform module is consumed by its short URL, which resolves through
Terraform/go-getter's HTTP module-source discovery protocol:

```hcl
module "state_bucket" {
  source = "https://noisypigeon.garden/terraform/cloudflare/bucket/v1.0.0"
}
```

The URL is a public interface of its own. It's deliberately decoupled from
wherever the source actually lives, so moving the source doesn't break a pin.
See [`pigeon-lib`'s `terraform/README.md`](https://github.com/noisypigeon/pigeon-lib/blob/main/terraform/README.md)
for the full contract, including the equivalent hand-written `git::` form and
how to iterate locally against an unreleased change.

The theme is consumed the same way: a Zola site pins a version and runs
`zola-site/resolve-theme.sh` out of a `pigeon-lib` checkout. This site does it
through [`fetch-lib.sh`](fetch-lib.sh) and [`.lib-version`](.lib-version).

## Releasing

**This repo cuts no releases.** Every versioned, reusable asset, meaning the
Terraform modules, the Zola theme and the shared CI, lives in
[`noisypigeon/pigeon-lib`](https://github.com/noisypigeon/pigeon-lib). That's
where a release PR and its `release:*` label belong. [`.lib-version`](.lib-version)
pins the version this repo consumes, and [`fetch-lib.sh`](fetch-lib.sh)
materializes it. A hub release dispatches
[`garden-pages.yml`](.github/workflows/garden-pages.yml) here, which rebuilds
the module pages from the hub's tags.

Every merged PR still gets exactly one line in the root
[`CHANGELOG.md`](CHANGELOG.md). `root-changelog.yml` writes it for every PR,
running `root-changelog.sh` out of the pinned library. DEV-0160 is that
contract.

## Decision records

This repo's ADRs live in [`adr/`](adr), as `DEV-NNNN-<slug>.md`. Each repo keeps
its own corpus:

- `noisypigeon/blog` holds `COM-` records (formerly `NPC-`);
- `noisypigeon/pigeon-lib` holds `LIB-` records;
- `noisypigeon/willowgraysen` holds `RUN-` records.

Bare `ADR-NNNN` in older prose and `DEV-NNNN` refer to the same records.

These records are directly relevant:

- **[LIB-0009](https://github.com/noisypigeon/pigeon-lib/blob/main/docs/adr/LIB-0009-terraform-short-urls-move-to-noisypigeon-garden.md):**
  the short-URL interface this site serves.
- **[DEV-0165](adr/DEV-0165-pigeon-dev-becomes-noisypigeon-garden.md):** this
  repo's domain, zone and Pages setup.
- **ADR-0112/0113/0114/0139:** the theme.
- **[DEV-0160](adr/DEV-0160-rename-adr-domain-to-pigeon-dev-and-root-changelog-contract.md):**
  the root-changelog contract.
