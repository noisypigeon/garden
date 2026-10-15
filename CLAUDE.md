# CLAUDE.md

This repo is `pigeon.dev`: the Zola site under `web/`, the short-URL host that
resolves Terraform module sources, and — since DEV-0163 — the Terraform that
serves the domain, under `terraform/`. It is a **spoke** in the hub-and-spoke
architecture of LIB-0001 — content plus the infrastructure that serves it,
consuming every reusable asset from the hub by pinned version.

## Terraform

`terraform/` follows LIB-0004's layout, `terraform/<provider>/<module>/<instance>/`,
where `<provider>/<module>` is exactly the pigeon-lib module the leaf calls. This
repo was its first adopter. Four leaves:

| Leaf | What it is |
| --- | --- |
| `cloudflare/dns-record/fastmail` | Fastmail's DKIM CNAMEs, MX and SPF |
| `cloudflare/dns-record/github-pages` | apex and `www` CNAMEs to GitHub Pages |
| `scaleway/project/dev` | this domain's Scaleway project |
| `scaleway/object-bucket/terraform-state` | this domain's Terraform state bucket |

A leaf calls exactly one pigeon-lib module (with `for_each` if it needs several
instances). A new leaf goes under that module's coordinate, with a kebab-case
`<instance>` naming what it is for. They were hoisted from `noisypigeon/noisypigeon`
with their history (DEV-0163) and renamed into this layout by moving their state
(LIB-0004 §3). Each leaf's state key is `terraform/<provider>/<module>/<instance>/terraform.tfstate`
in this domain's own bucket, because `root.hcl` sits at this repo's root (LIB-0001
invariant 4). **Moving `root.hcl` or a leaf changes its state key** — don't,
without LIB-0004 §3's runbook: `state pull`/`push` via a worktree of `main`, then
`state rm` everything at the old key.

- **`root.hcl` is generated — never edit it.** It is pigeon-lib's
  `terragrunt/root-hcl` template at the version `spoke.hcl` pins
  (`root_hcl_version`), copied by `.lib-src/.github/scripts/resolve-root-hcl.sh`
  and committed. Committed rather than ignored because Terragrunt's git filter
  plans inside git worktrees, which only hold tracked files (LIB-0003). CI runs
  the resolver with `--check` and fails on drift. To take a template change, bump
  `root_hcl_version`, run `mise run terraform-prepare`, commit the diff.
- **`spoke.hcl`** holds this spoke's instance values: the template version and
  `state_bucket_secret` (`PIGEON_DEV_TERRAFORM_STATE_BUCKET_NAME`).
- **Secrets** are in `terraform/secrets.enc` (sops/age, dotenv; `.sops.yaml` has
  the recipient). Edit with `mise run secrets-edit`. CI decrypts with the
  `SOPS_AGE_KEY` repo secret.
- **`state/iam` is not here.** It mints the deploy key these leaves authenticate
  with, and must not depend on that key, so it stays in `noisypigeon/noisypigeon`
  on that repo's shared root and shared state bucket (LIB-0001 §8; DEV-0130/0133;
  DEV-0163). Rotating the deploy key is a PR *there*, then a `secrets-edit` here.

A Terraform PR is planned by `terragrunt-plan.yml` and applied by commenting
`terragrunt apply` on it (`terragrunt-apply.yml`; ADR-0124/0129). A successful
apply sets the `terragrunt/apply` status this repo's ruleset requires and
squash-merges the PR. Never merge a Terraform PR any other way.

`templates/` is gone. DEV-0162 moved `templates/terraform/` and
`templates/zola-site/` to `noisypigeon/pigeon-lib`, where they live as
`terraform/` and `zola-site/`, are tagged
`terraform/<provider>/<module>/vX.Y.Z` and `zola-site/vX.Y.Z`, and own their
`CHANGELOG.md` files. The shared CI went with them, tagged `workflows/vX.Y.Z`.
Do not add a module, a theme file, or a reusable script here — it belongs in the
hub.

What stayed, and why: `pigeon.dev/modules/<provider>/<module>/vX.Y.Z` is a
public interface with a stability guarantee (ADR-0109/0110), and serving it is a
property of the domain rather than of the code. The redirect pages, module
overview pages and release posts that implement it are generated into
`web/content` at build time by the hub's
`.github/scripts/generate-module-redirects.sh`, reading the **hub's** tags and
`CHANGELOG.md` files out of the fetched `.lib-src/`. The public URL path is
`modules/…` and always was — decoupling it from internal layout is exactly what
let the source move out from under it without breaking a pin.

The history is worth knowing when reading older records: ADR-0154 hoisted
`templates/` here from `noisypigeon/noisypigeon` keeping the `templates/…` paths
byte-identical, and ADR-0156 then hoisted the site in as `pigeon.dev/src`
alongside it,
which let the generator read `templates/` off local disk and let
`resolve-theme.sh` use a live `"main"` symlink. DEV-0162 undid both of those
localisations: everything is fetched again now, but pinned to a version rather
than tracking a branch, and renamed the site root from `pigeon.dev/src` to
`web/` -- a repo named `pigeon.dev` does not need a directory named
`pigeon.dev` inside it.

See `README.md` for the consumption contract.

## Where the decisions live

ADRs live in this repo, flat under `adr/`, as `DEV-NNNN-<slug>.md` — hoisted
here from `noisypigeon/noisypigeon/docs/adr/` by ADR-0157, renamed from
`adr/infrastructure/` with `DEV-` IDs by DEV-0160, and flattened out of
`adr/pigeon.dev/` by DEV-0161 once each repo started carrying its own corpus.
The siblings now live in their own repos: `COM-` records in `noisypigeon.com` (`NPC-` in older prose is an alias, COM-0001),
`LIB-` records in `pigeon-lib`, `RUN-` records in `willowgraysen.com`. Before making an architectural or interface change here, read the
relevant ADRs and keep new work consistent with them; if a change would
contradict one, flag it rather than silently diverging, and prefer writing a new
ADR over undocumented drift.

Filing a `pigeon.dev` ADR, by hand — `adr-new.sh` lives in
`noisypigeon/noisypigeon` and still hardcodes the old path, so it cannot create
these (DEV-0160):

- **Number**: max+1 **within `adr/`**, which is the only sequence it shares. `0136`, `0138` and `0156` are each used twice already, from parallel
  branches — check before claiming a number.
- **Filename and H1 agree**: `DEV-0160-<slug>.md` holds `# DEV-0160: <title>`.
- **Author is always** `Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).`
  Records dated before 2026-10-03 say `Willow Finch` and are correct as filed;
  do not retrofit them.
- **Sections**: `## Context` / `## Decision` / `## Consequences` /
  `## Out of scope`, optionally then `## Verification`. No YAML frontmatter, and
  no index or registry to update — there isn't one.
- **Citations**: cite `DEV-NNNN`. Bare `ADR-NNNN` in existing prose means the
  same record — DEV-0160 renamed the files and H1s but grandfathered the ~1,100
  in-text citations, so the two spellings are aliases for this corpus.
- Genuinely-deferred `## Out of scope` items get a GitHub issue filed against
  `noisypigeon/noisypigeon` (ADR-0031); permanent design boundaries do not.

The load-bearing ones for this repo: ADR-0154 (the split that brought
`templates/` here; its prefix→repo mapping, which kept 20 legacy `modules/*`-era
tags resolving against `noisypigeon/noisypigeon`, was retired by DEV-0160 step 0
once nothing pinned them — every module tag now lives here, under one prefix),
ADR-0037/0093/0110 (this directory's prior homes and why old tags still
resolve), ADR-0109/0136 (the short-URL redirect
mechanism and its move to the `pigeon.dev` host), ADR-0119/0120/0153 (the
modules' current composition shape), ADR-0112/0113/0114/0139 (the theme, its
versioning, and its resolution), and ADR-0156 (hoisting `pigeon.dev/src` here
and cutting its deploy over from a Scaleway bucket to GitHub Pages).

## Dev cycle

Every change ships through a PR. There is no human reviewer. `main` has a
ruleset (DEV-0163, copied from `noisypigeon`'s ADR-0129): no force-push, and the
`terragrunt/apply` status is required — `terragrunt-plan.yml`'s detect job sets
it to success straight away for a PR touching no Terraform. **This repo cuts no
releases and carries no `release:*` label** —
since DEV-0162 it is a spoke, holding content and its own deploy, and every
versioned asset lives in `noisypigeon/pigeon-lib`. A release PR belongs there.

Every merged PR gets exactly one line in the root `CHANGELOG.md`, under a
`## YYYY-MM-DD` section, newest first. That is DEV-0160's contract, and
`root-changelog.yml` is now its only writer here — it runs on every merged PR
with no `paths:` filter and no stand-down case, since there is no longer a
`template-release.yml` to hand off to. The root file's
`<!-- entries below; newest first -->` marker is where entries get inserted —
the script refuses to write without it.

Four workflows, all thin callers reading their logic out of the pinned library:

- `root-changelog.yml` — a thin caller of `pigeon-lib`'s reusable
  `spoke-root-changelog.yml`, passing this repo's tag precedence (`web/` →
  `pigeon.dev`, `terraform/`, `root.hcl`, `spoke.hcl` or `.sops.yaml` →
  `terraform`, `adr/` → `adr`, `.github/` → `ci`, else `repo`). The reusable
  fetches the library and runs its `root-changelog.sh`.
- `terragrunt-plan.yml` / `terragrunt-apply.yml` — thin callers of
  `pigeon-lib`'s `terragrunt-detect.yml` and `terragrunt-run.yml`; see
  "Terraform" above.
- `pigeon-dev-pages.yml` — a thin caller of `pigeon-lib`'s reusable
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
`pigeon-lib` one merges, tags and dispatches the deploy first, then the
consumer's `source =` pin is bumped in `noisypigeon/noisypigeon`. For local
iteration before tagging, point `LIB_SRC` at a sibling `pigeon-lib` clone and
`fetch-lib.sh` leaves it alone.

## Commands

- `mise run pigeon-dev-build` / `mise run pigeon-dev-serve` — build / serve
  `web/` with Zola. Each fetches the pinned library, resolves the
  theme out of it, regenerates the redirect/overview/release pages, then runs
  `zola build`/`zola serve`.

- `mise run plan` / `mise run apply` — fetch the library, regenerate `root.hcl`,
  then `terragrunt run --all`. Prefer the PR flow for `apply`.
- `mise run terraform-prepare` — just the fetch and `root.hcl` regeneration.
- `mise run fmt-terraform` / `mise run fmt-check-terraform`.
- `mise run secrets-edit` — edit `terraform/secrets.enc` in place.
