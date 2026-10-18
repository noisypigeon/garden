# CLAUDE.md

This repo is `noisypigeon/garden`. It holds the Zola site under `web/`, published at
`https://noisypigeon.garden`, which is also the short-URL host that resolves
Terraform module sources (LIB-0009). It also holds the Terraform that serves
the domain, under `terraform/`. It is a **spoke** in the hub-and-spoke
architecture of LIB-0001 — content plus the infrastructure that serves it,
consuming every reusable asset from the hub by pinned version.

## Terraform

`terraform/` follows LIB-0004's layout, `terraform/<provider>/<module>/<instance>/`,
where `<provider>/<module>` is exactly the library module the leaf calls. This
repo was its first adopter. A leaf calling a zone-scoped Cloudflare module adds the
zone, `terraform/cloudflare/<zone>/<module>/<instance>/` (LIB-0008), and passes
`zone = local.cloudflare_zone`, which `root.hcl` derives from the path; the module
looks the zone's ID up by apex (LIB-0011). Four leaves:

| Leaf | What it is |
| --- | --- |
| `cloudflare/noisypigeon.garden/dns-record/github-pages` | `noisypigeon.garden`'s apex and `www` CNAMEs to GitHub Pages (DEV-0165) |
| `cloudflare/bucket/terraform-state` | this domain's R2 Terraform state bucket (LIB-0007, DEV-0164) |
| `backblaze/bucket/terraform-state-backup` | the versioned offsite copy of the R2 state |
| `backblaze/api-key/terraform-state-backup` | the list-and-write-only key `state-backup.yml` copies with |

A leaf calls exactly one library module (with `for_each` if it needs several
instances). A new leaf goes under that module's coordinate, with a kebab-case
`<instance>` naming what it is for. Each leaf's state key is its path plus `/terraform.tfstate`
in this domain's own R2 bucket, because `root.hcl` sits at this repo's root (LIB-0001
invariant 4). **Moving `root.hcl` or a leaf changes its state key** — don't,
without LIB-0008 §3: copy the state object to the new key, check it against a
worktree of `main`, plan `No changes.`, then `state rm` everything at the old key.

- **`root.hcl` is generated — never edit it.** It is the library's
  `terragrunt/root-hcl` template at the version `spoke.hcl` pins
  (`root_hcl_version`), copied by `.lib-src/.github/scripts/resolve-root-hcl.sh`
  and committed. Committed rather than ignored because Terragrunt's git filter
  plans inside git worktrees, which only hold tracked files (LIB-0003). CI runs
  the resolver with `--check` and fails on drift. To take a template change, bump
  `root_hcl_version`, run `mise run terraform-prepare`, commit the diff.
- **`spoke.hcl`** holds this spoke's instance values: the template version,
  `state_backend = "cloudflare"` (LIB-0007, DEV-0164) and the `providers` map
  (LIB-0005) — `cloudflare` on for every leaf, `backblaze` for
  `terraform/backblaze/` only. Scaleway is off: this domain has had no Scaleway
  resources since DEV-0164.
- **State is on Cloudflare R2, backed up to Backblaze B2** (DEV-0164). R2 has no
  object versioning, so `state-backup.yml` copies every state object to a
  versioned B2 bucket after each apply and daily. Its B2 key can list and write,
  never read or delete. A restore needs an admin B2 key, by hand, through B2's
  native API: follow the library's
  [`docs/runbooks/restore-terraform-state-from-b2.md`](https://github.com/noisypigeon/library/blob/main/docs/runbooks/restore-terraform-state-from-b2.md).
  Here the backup bucket is `dev-65bctm-terraform-state-backup`, in B2's
  `ca-east-006` region.
- **Secrets** are one sops/age dotenv file per concern under `terraform/secrets/`
  (LIB-0012; `.sops.yaml` has the recipient): `terraform.enc` holds the R2 state's
  `TERRAFORM_STATE_*` and, because `spoke.hcl` sets `state_backup = true`, its B2
  copy's `TERRAFORM_STATE_BACKUP_*`; `cloudflare.enc` and `backblaze.enc` hold
  `CLOUDFLARE_PROVIDER_*` and `BACKBLAZE_PROVIDER_*`. Each file holds exactly the
  keys `/secrets-schema.json` gives it, and each leaf decrypts only the files it
  uses. Edit one with `mise run secrets-edit <file>`, e.g. `secrets-edit cloudflare`.
  CI decrypts with the `SOPS_AGE_KEY` repo secret, and `check-secrets.sh` checks
  every file's key names without decrypting. The R2 S3 keys (`TERRAFORM_STATE_ACCESS_KEY*`) are made by
  hand in the Cloudflare dashboard — there is no Terraform resource for them —
  scoped to the state bucket with *Object Read & Write*.

A Terraform PR is planned by `terragrunt-plan.yml` and applied by commenting
`terragrunt apply` on it (`terragrunt-apply.yml`; ADR-0124/0129). A successful
apply sets the `terragrunt/apply` status this repo's ruleset requires and
squash-merges the PR. Never merge a Terraform PR any other way.

The Terraform modules and the Zola theme live in `noisypigeon/library` as
`terraform/` and `zola-site/`, are tagged
`terraform/<provider>/<module>/vX.Y.Z` and `zola-site/vX.Y.Z`, and own their
`CHANGELOG.md` files. The shared CI went with them, tagged `workflows/vX.Y.Z`.
Do not add a module, a theme file, or a reusable script here — it belongs in the
hub.

What stayed, and why: `noisypigeon.garden/terraform/<provider>/<module>/vX.Y.Z`
is a public interface (LIB-0009), and serving it is a
property of the domain rather than of the code. The generated pages land in
`web/content/terraform/` (redirect and overview pages),
`web/content/theme-versions/` and `web/content/releases/`. The hub's
`.github/scripts/generate-module-redirects.sh` writes them at build time,
reading the **hub's** tags and `CHANGELOG.md` files out of the fetched
`.lib-src/`. Only each directory's `_index.md` is tracked.
**A failed deploy here breaks every consumer's `terraform init`.**

See `README.md` for the consumption contract.

## Where the decisions live

This repo holds no ADRs. It is a spoke, and its design standards come from
`noisypigeon/library`, so its decisions live there too (LIB-0017):

- **A new decision about this repo** is an amendment on the `LIB-` record whose
  standard it applies, or a new `LIB-` record. File it in library, and land it
  before the change here that depends on it.
- **The `DEV-` records that used to live here** are archived verbatim in
  library's `docs/adr/archive/`. That domain is closed: no new `DEV-` number is
  issued. DEV-0162 to DEV-0165 are also folded into LIB-0002, LIB-0003,
  LIB-0007 and LIB-0009 as amendments.
- **Citations are never rewritten.** `DEV-NNNN` and bare `ADR-NNNN` in existing
  prose, comments and changelogs are the same record, and can be found in the
  archive by number. `0136`, `0138` and `0156` are each used twice there.

Before an architectural or interface change here, read the relevant records
and keep new work consistent with them. If a change would contradict one, flag
it rather than silently diverging.

The load-bearing ones for this repo:

- LIB-0009, the `noisypigeon.garden/terraform/` short-URL interface this site
  serves;
- DEV-0165, folded into LIB-0009, for this repo's domain, zone and Pages setup;
- DEV-0156, the GitHub Pages deploy;
- DEV-0112/0113/0114/0139, the theme, its versioning and its resolution;
- DEV-0163 and DEV-0164, folded into LIB-0003 and LIB-0007, for this repo's
  Terraform and its R2 state.

## Dev cycle

Every change ships through a PR. There is no human reviewer. `main` has a
ruleset (DEV-0163, copied from `noisypigeon`'s ADR-0129): no force-push, and the
`terragrunt/apply` status is required — `terragrunt-plan.yml`'s detect job sets
it to success straight away for a PR touching no Terraform. **This repo cuts no
releases and carries no `release:*` label** —
it is a spoke, holding content and its own deploy, and every
versioned asset lives in `noisypigeon/library`. A release PR belongs there.

Every merged PR gets exactly one line in the root `CHANGELOG.md`, under a
`## YYYY-MM-DD` section, newest first. That is DEV-0160's contract, and
`root-changelog.yml` is now its only writer here — it runs on every merged PR
with no `paths:` filter and no stand-down case, since there is no longer a
`template-release.yml` to hand off to. The root file's
`<!-- entries below; newest first -->` marker is where entries get inserted —
the script refuses to write without it.

Five workflows, all thin callers reading their logic out of the pinned library:

- `root-changelog.yml` — a thin caller of `library`'s reusable
  `spoke-root-changelog.yml`, passing this repo's tag precedence (`web/` →
  `garden`, `terraform/`, `root.hcl`, `spoke.hcl` or `.sops.yaml` →
  `terraform`, `adr/` → `adr`, `.github/` → `ci`, else `repo`). The reusable
  fetches the library and runs its `root-changelog.sh`.
- `terragrunt-plan.yml` / `terragrunt-apply.yml` — thin callers of
  `library`'s `terragrunt-detect.yml` and `terragrunt-run.yml`; see
  "Terraform" above. `terragrunt-apply.yml`'s `backup` job then calls
  `state-backup.yml`, even after a failed apply.
- `state-backup.yml` — a thin caller of `library`'s `state-backup.yml`, daily
  and on `workflow_dispatch`: copies the R2 state to its B2 backup (DEV-0164).
- `garden-pages.yml` — a thin caller of `library`'s reusable
  `zola-site-pages.yml`, which resolves the theme and regenerates the redirect
  pages, overview pages and release posts from the **library's** tags and
  `CHANGELOG.md` files before `zola build`. `actions/deploy-pages` always
  deploys to the *calling* repo's Pages site, which is why this caller is here
  and not in the hub.

`.lib-version` pins the library ref all of them consume; `fetch-lib.sh`
materializes it into a gitignored `.lib-src/`. Bumping that pin is how this repo
takes a library change — never by tracking a branch (LIB-0001 invariant 2).
`fetch-lib.sh` is the deliberate exception to "a spoke contains no scripts": a
spoke cannot fetch its own fetcher.

A change spanning a module and its consumer is two PRs in two repos: the
`library` one merges, tags and dispatches the deploy first, then the
consumer's `source =` pin is bumped in each spoke that uses it. For local
iteration before tagging, point `LIB_SRC` at a sibling `library` clone and
`fetch-lib.sh` leaves it alone.

## Commands

- `mise run garden-build` / `mise run garden-serve` — build / serve
  `web/` with Zola. Each fetches the pinned library, resolves the
  theme out of it, regenerates the redirect/overview/release pages, then runs
  `zola build`/`zola serve`.

- `mise run plan` / `mise run apply` — fetch the library, regenerate `root.hcl`,
  then `terragrunt run --all`. Prefer the PR flow for `apply`.
- `mise run terraform-prepare` — just the fetch and `root.hcl` regeneration.
- `mise run fmt-terraform` / `mise run fmt-check-terraform`.
- `mise run secrets-edit <file>` — edit `terraform/secrets/<file>.enc` in place.
