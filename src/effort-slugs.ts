/**
 * extractEffortSlugs — port of wod-wiki's
 * apps/playground/src/services/storage/StorageService.ts (the pure function
 * only). Derives canonical effort slugs referenced by script statements for
 * the block-efforts containment index.
 */
import type { ICodeStatement } from '@bitcobblers/wod-wiki-lang';

export function extractEffortSlugs(statements: ICodeStatement[]): string[] {
  const slugs = new Set<string>();
  for (const statement of statements) {
    if (statement.exerciseId) {
      slugs.add(statement.exerciseId);
    } else {
      const effortMetric = statement.metrics?.getMetric?.('effort');
      if (effortMetric?.effort) {
        const slug = effortMetric.effort.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
        if (slug) slugs.add(slug);
      }
    }
  }
  return Array.from(slugs);
}
