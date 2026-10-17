# wod-wiki-community

The Wod.Wiki community content corpus, built via the `wod` CLI
(from [`@bitcobblers/wod-wiki-tools`](https://www.npmjs.com/package/@bitcobblers/wod-wiki-tools))
into versioned artifacts the [wod-wiki](https://github.com/bitcobblers/wod-wiki)
app imports at boot.

This repo is the home for community bundled content: workout programs
(collections), dated programming (feeds), prebuilt dashboards, and the
effort registry. Content changes land here as merge requests; the CLI
validates them and stamps every build with this repo's git version so the
app (and you) can tell exactly what changed and what needs syncing.

The app's own playground pages (the `canvas` corpus — home, guide, syntax,
WQL presets) live in the wod-wiki repo under `markdown/canvas/` and are
compiled into the app's **core** seed by the same CLI; this repo
builds the **community** seed. The app imports both as independent seed
sources (per-source manifests, versions, and checkpoints), and any other
seed library laid out as `markdown/<corpus>/…` can be consumed the same way.

## Layout

```
markdown/            the corpus (the only thing most MRs touch)
  collections/       named workout libraries — one dir per catalog, README + items
  feeds/             dated programming — feeds/<slug>/<yyyy-mm-dd>/<item>.md
  dashboards/        prebuilt dashboard notes (locked #899 format)
  efforts/           effort registry documents (frontmatter: slug/label/aliases/baseAttributes/equipment)
  equipment/         equipment registry documents (frontmatter: slug/label/aliases) resolved against workouts
dist/                build output (gitignored)
```

## Build

```sh
npm install      # once — installs the wod CLI (devDependency @bitcobblers/wod-wiki-tools)
npx wod build    # or: npm run build — compiles markdown/ → dist/ (manifest + chunks + report.html)
npm run validate # the same build — what CI runs on every MR
```

Validation is the **parity gate** plus dashboard-note validation, both run
inside `wod build`. The parity gate is the core check: every `.md` under
`markdown/` must belong to a known corpus (`dashboards | efforts |
collections | feeds` — plus `canvas` when a seed carries routable pages) and
land in exactly one chunk, or the build fails. A new top-level
directory cannot silently bypass the pipeline.

`wod build --scaffold` (`npm run build:scaffold`) additionally scans workout
blocks for effort labels missing from the registry and scaffolds
`markdown/efforts/discovered/*.md` stubs for curation.

## Publishing

Every push to `main` builds the corpus and deploys `dist/` to GitHub Pages at
**https://bitcobblers.github.io/wod-wiki-community/**. `manifest.json` is
fetched with `no-cache` so the app always sees the latest manifest, while
chunk filenames are content-hashed and can be cached forever. Consume the
seed in the app via **Settings → Sync → add custom seed source** with that
URL. PRs get a validation comment with the manifest summary (version + chunk
table).

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

The wod-wiki app does NOT bundle this corpus. This repo's `main` pipeline
builds the corpus with `wod build` and deploys the artifacts to this repo's
GitHub Pages (above). The app's runtime fetches that published
`manifest.json` + chunks over HTTP (the default "Community" seed source in
`seedSync.ts`) and applies them to IndexedDB; per-chunk sha256 checkpoints
mean only changed chunks re-import. The app repo only bundles its own core
seed (playground canvas pages) — community content always flows through
this Pages publish.

## Content tooling

- `npm run docs:check` — verify corpus-internal markdown links resolve.
- `node scripts/omf.mjs` — inventory/prune frontmatter properties across the corpus.
- `node scripts/migrate-corpus-tags.ts` — bulk frontmatter tag migrations.

## License

GPL-3.0 (see LICENSE) — inherited from wod-wiki. Content contributions are
licensed the same.
