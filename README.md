# wod-wiki-seed

The Wod.Wiki community content corpus and the seed compiler that turns it
into versioned artifacts the [wod-wiki](https://github.com/bitcobblers/wod-wiki)
app imports at boot.

This repo is the single home for bundled content: workout programs
(collections), dated programming (feeds), guide/syntax pages (canvas),
prebuilt dashboards, and the effort registry. Content changes land here as
merge requests; the compiler validates them and stamps every build with this
repo's git version so the app (and you) can tell exactly what changed and
what needs syncing.

## Layout

```
markdown/            the corpus (the only thing most MRs touch)
  canvas/            routable guide/syntax pages (frontmatter route: + template: canvas)
  collections/       named workout libraries — one dir per catalog, README + items
  feeds/             dated programming — feeds/<slug>/<yyyy-mm-dd>/<item>.md
  dashboards/        prebuilt dashboard notes (locked #899 format)
  efforts/           effort registry documents (frontmatter: slug/label/aliases/baseAttributes)
src/
  compiler.ts        the seed compiler (parity gate → content-hashed chunks)
  contract.ts        manifest/chunk contract shared with the app (shape-compatible copy)
  git-version.ts     version derivation from git history
  report.ts          dist/report.html build benchmark page
vendor/@bitcobblers/ prebuilt wod-wiki parser packages (gitignored, see below)
dist/                build output (gitignored): manifest.json, chunks/, report.html
```

## Build

```sh
bun install   # once
bun run build # compiles markdown/ → dist/ (manifest + chunks + report.html)
bun test      # parity gate, partition, determinism, dashboard-seed validation
bun run validate # test + build — what CI runs
```

The **parity gate** is the core validation: every `.md` under `markdown/`
must belong to a known corpus (`canvas | dashboards | efforts | collections |
feeds`) and land in exactly one chunk, or the build fails. A new top-level
directory cannot silently bypass the pipeline.

`bun run build:scaffold` additionally scans workout blocks for effort labels
missing from the registry and scaffolds `markdown/efforts/discovered/*.md`
stubs for curation.

## Versioning

The manifest **is** this repo's git history:

| field | source | purpose |
|---|---|---|
| `version` | `git rev-list --count HEAD` | monotonic import order for the app |
| `versionLabel` | `git describe --tags --long --always --dirty` | human-readable, e.g. `v1.2.0-4-gdeadbee` |
| `commit` | `git rev-parse HEAD` | exact source tree |
| `dirty` | `git status --porcelain` | false when built from a clean tree |

Chunk content changes are detected by per-chunk `sha256` in the manifest —
the app stores applied hashes and only re-imports chunks that changed. To see
what changed between two builds, diff their manifests (or open
`dist/report.html` from each).

Tag releases with `git tag v1.2.0` to give `versionLabel` a semver anchor.

## How the app consumes this

`wod-wiki/scripts/sync-seed.ts` imports the compiler from this repo
(expected as a sibling checkout at `../wod-wiki-seed`, override with
`WOD_WIKI_SEED_DIR`), passes its playground template as an extra chunk, and
writes the result to `apps/playground/public/seed/`. The app's runtime then
fetches `manifest.json` + chunks over HTTP and applies them to IndexedDB.

## Vendored parsers (local-only, gitignored)

`vendor/@bitcobblers/` carries prebuilt `wod-wiki-core/lang/wql` dists so
this repo builds standalone and its block derivations stay bit-identical
with the app runtime. The registry versions of these packages have drifted
from the app monorepo — do not replace the vendored copies with registry
versions.

`vendor/` is **not checked in**. After a fresh clone, populate it from a
sibling wod-wiki checkout, then install:

```sh
./scripts/vendor-parsers.sh ../wod-wiki
bun install
```

To refresh after parser changes in the app repo, rebuild the packages there
(`bun run --cwd packages/<name> build`) and re-run the script.

ponytail: temporary mechanism — once the monorepo packages are republished
properly, this repo switches to registry version pins and `vendor/` +
the script go away.

## Content tooling

- `bun run docs:check` — verify corpus-internal markdown links resolve.
- `bun scripts/omf.mjs` — inventory/prune frontmatter properties across the corpus.
- `bun scripts/migrate-corpus-tags.ts` — bulk frontmatter tag migrations.

## License

GPL-3.0 (see LICENSE) — inherited from wod-wiki. Content contributions are
licensed the same.
