# ADR-0003: Deletion and freshness strategy for the search index

- Status: proposed (to be confirmed with measurements on Day 39)
- Date: 2026-11-20
- Deciders: repo owner

## Context
The search index is a derived copy of documents held in OneLake. Documents are deleted, edited and have their permissions changed at the source, and the index does not learn about any of this unless the pipeline tells it. If a deleted or restricted document stays retrievable, the copilot can quote content a user should no longer see. That is a security and compliance failure, not just a quality issue.

Requirements driving the decision:
- Requirements are tiered by data class: sensitive content must stop being retrievable within 5 minutes and general content within 1 hour (assumed targets, to be confirmed with security and compliance). The 15-minute figure used below is the default for the first build.
- A permission change must be reflected in query results within 15 minutes.
- Content must be physically purged from the index and its caches within 24 hours, so that erasure requests can be met well inside the one-month UK GDPR limit.
- Edits must never leave a gap where a document has no chunks.
- Embedding calls cost money, so re-processing unchanged documents should be avoided.

Every chunk stores doc_id, chunk_no, content_hash and allowed_groups, so chunks can be traced back to their source and filtered by permission.

## Options considered
1. Full nightly re-index: simple and self-correcting, but deletions persist for up to 24 hours, which fails the 15-minute target, and it re-embeds everything every night at high cost.
2. Change feed with incremental updates only: low latency and low cost, but one missed event, failed run or restore leaves orphaned chunks in the index forever, and nothing would reveal it.
3. Change feed with incremental updates, immediate tombstone filtering and a nightly reconciliation job: meets the latency targets, keeps costs low, and the reconciliation job catches missed events; but it has more moving parts to build, run and monitor.
4. Managed indexer with built-in deletion detection: the least code to maintain, but it depends on whether the chosen data source supports it, and it gives less control over chunking, permission metadata and ordering of writes.

## Decision
Adopt option 3: read the Delta change feed incrementally, mark deleted documents as tombstoned in the index so queries filter them out immediately, purge them physically afterwards, and run a nightly reconciliation job that compares doc_ids in OneLake with those in the index.

The single most important reason: option 3 is the only option that meets both the 15-minute removal target and the need to detect silent pipeline failure. Option 1 fails the latency target, and option 2 cannot tell me when it has drifted.

If the requirement were relaxed to 24 hours and the corpus stayed small, I would choose option 1 for its simplicity and treat the nightly rebuild as the audit.

Updates write new chunks first, then delete old chunks identified by an older content_hash, so users never hit a gap.

## Consequences
- Easier: deleted and restricted content disappears quickly, the index can be audited, and unchanged documents are not re-embedded.
- Harder: more components to build and monitor (change feed reader, tombstone filter, purge step, reconciliation job, alerting).
- The search service has no delete-by-filter command, so purging means querying chunk keys by doc_id and deleting them in batches.
- Other copies must be purged too: semantic cache, conversation history, logs and evaluation datasets. These need an inventory and an owner.
- Test to build: delete a document in OneLake, then assert it is not retrievable within 15 minutes and is physically absent within 24 hours. Add a second test for a permission change.
- Revisit on Day 39 once real measurements exist, and again if the managed indexer (option 4) gains deletion support for my data source.
- Permission changes are bounded by how quickly user group membership refreshes (token lifetime), not just by index latency. Revisit with continuous access evaluation or live group lookup if sensitive tiers need faster revocation.

## Evidence
No measurements yet. To collect on Day 39: end-to-end delete latency, re-embedding cost per day for options 1 and 3, and the number of orphans the reconciliation job finds in a deliberately broken test run.
