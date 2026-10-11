# Contributing content

Merge requests here add programs, workouts, dashboards, and efforts to the
community system. Every MR goes through the same validation the build runs.

## Quick path

1. Fork, branch, add/edit files under `markdown/` only.
2. `bun install && bun run validate` — tests + full compile must pass.
3. Open the MR. CI runs the same `bun run validate`.

## Corpus rules (enforced by the build)

- **Collections** — `markdown/collections/<catalog>/`: one directory per
  catalog, a `README.md` (frontmatter `category:` list + prose), and one
  `.md` per item. Workout blocks use the Whiteboard Language (```time /
  ```wod fences). A new catalog directory is picked up automatically as its
  own seed chunk.
- **Feeds** — `markdown/feeds/<slug>/<yyyy-mm-dd>/<item>.md`, one item per
  date directory.
- **Canvas guides** — live in the wod-wiki repo (`markdown/canvas/`), not
  here; this repo's compiler still compiles them when the app builds its
  core seed. Community seeds MAY carry routable pages the same way
  (frontmatter `template: canvas` + `route: /...`); fragments/snippets
  without a route stay out of the Library index by design.
- **Dashboards** — locked #899 note format; widget types and `$token`
  references are validated by `test/dashboard-seeds.test.ts` (WQL bodies
  must parse).
- **Efforts** — frontmatter documents (`slug`, `label`, `aliases`,
  `baseAttributes.met` > 0, optional `discipline`/`intensityTier`).
  Unregistered effort labels referenced by workouts are reported by
  `bun run build:scaffold`, which drafts stubs under
  `markdown/efforts/discovered/` for curation.
- A new top-level directory under `markdown/` **fails the build** (parity
  gate) until the compiler's corpus partition learns it — open an issue or
  extend `chunkIdFor` in `src/compiler.ts`.

## What lands in an MR

- Content edits (the common case): only `markdown/` changes. The manifest
  and chunk hashes regenerate at release time — never commit `dist/`.
- Parser/compiler changes: rare, need discussion — they affect every
  consumer of the artifacts. Keep `src/contract.ts` shape-compatible with
  the app's `apps/playground/src/types/seed.ts`.

## Release flow (maintainers)

Merges to `main` advance `manifest.version` (commit count). To cut a
release the app should pin: `git tag vX.Y.Z`, then run `bun run build` and
point the app's sync at the new tag/commit. The app diffs manifests to
decide which chunks to re-import.
