# ADR-0002: Monorepo vs separate repos for the portfolio

- Status: accepted
- Date: 2026-11-19
- Deciders: repo owner

## Context
I am building six projects over 120 days. Reviewers will spend only a couple of minutes on my GitHub, and I want them to see the architecture story first. I work alone, so coordination overhead and CI maintenance matter more than team ownership.

## Options considered
1. One monorepo with a folder per project: shared templates, ADRs and CI; one place to review; but GitHub cannot pin a folder, and individual projects get no separate stars or release history.
2. Six separate repos: each project can be pinned and starred, and has its own README landing page; but templates and CI would be duplicated six times and the overall story is fragmented.
3. Monorepo plus separate repos published from it (subtree or split): best of both worlds in visibility; but it adds a sync process that I would have to maintain and debug.
4. GitHub organisation with separate repos plus a profile README linking them: good for visibility; same duplication problem as option 2, plus org overhead.

## Decision
Use a single monorepo. The most important reason: one shared set of templates, ADRs and CI gates keeps all six projects consistent at the lowest cost for a solo builder, and gives reviewers one place to see the whole architecture story.

## Consequences
- Easier: consistent standards, one CI pipeline, one narrative.
- Harder: I cannot pin individual projects, so my profile README will link directly to project folders.
- Revisit at Day 105: if one project attracts attention, extract it into its own repo with its history preserved.

## Evidence
No benchmarks apply to this decision. It is based on my constraints (solo, 120 days, reviewer attention) and the cost comparison of the options above.
