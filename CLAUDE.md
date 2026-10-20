# CLAUDE.md

`noisypigeon/garden` serves `noisypigeon.garden`: a Zola site under `web/`, and
the `noisypigeon.garden/terraform/...` short URLs that resolve every Terraform
module source. `terraform/` holds the domain's DNS and its state buckets.

It is a spoke of `noisypigeon/library`. Modules, the theme, CI logic, scripts
and decision records all live there. Don't add them here.

## Dev cycle

- Every change is a PR with a Conventional Commit title. There is no human
  reviewer.
- `CHANGELOG.md` is generated, one line per merged PR. Don't hand-edit it.
- This repo cuts no releases and has no `release:*` labels.
- Take a library change by bumping `.lib-version`, and the `@workflows/vX.Y.Z`
  refs in `.github/workflows/`, never by tracking a branch. For local
  iteration, point `LIB_SRC` at a library checkout.
- A change to a module or the theme is a library PR first, then a pin bump
  here.

## Hazards

- **A failed deploy breaks every consumer's `terraform init`.** A library
  release dispatches `garden-pages.yml`, which regenerates the module pages from
  library's tags.
- Under `web/content/{terraform,theme-versions,releases}/`, only `_index.md` is
  tracked. The rest is generated at build time.

## Terraform

- Leaves are `terraform/<provider>/<module>/<instance>/`, plus the zone for
  zone-scoped Cloudflare modules. Each leaf calls one library module.
- A leaf's path is its state key. Don't move one without a state move.
- **`root.hcl` is generated. Never edit it.** Bump `root_hcl_version` in
  `spoke.hcl`, run `mise run terraform-prepare` and commit the diff.
- Secrets are sops files under `terraform/secrets/`. Edit one with
  `mise run secrets-edit <file>`.
- A Terraform PR is planned on the PR. Comment `terragrunt apply` to apply
  exactly that plan and merge it. Never merge one any other way. If apply says
  the plan is missing or stale, comment `terragrunt plan` to plan again, after
  rebasing if `main` changed the same leaves (LIB-0022).
- State is on R2, copied to B2 after every apply. To restore it, see library's
  `docs/runbooks/restore-terraform-state-from-b2.md`.

## Commands

- `mise run garden-build` / `mise run garden-serve`
- `mise run plan` / `mise run apply` (prefer the PR flow)
- `mise run terraform-prepare`
- `mise run fmt-terraform` / `mise run fmt-check-terraform`
- `mise run secrets-edit <file>`
