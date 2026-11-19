# ADR-0001: Record architecture decisions

- Status: accepted
- Date: 2026-11-19
- Deciders: repo owner

## Context
This portfolio exists to show how I make trade-offs. Decisions made in my head are invisible to reviewers and to future me.

## Options considered
1. No written record: fastest, but nothing to show or revisit.
2. Long design documents: thorough, but rarely kept up to date.
3. Lightweight ADRs, one per decision: cheap, versioned with the code.

## Decision
Use lightweight ADRs in docs/adr, one per significant decision, numbered sequentially.

## Consequences
Small per-decision overhead. Every project can be explained through its ADR trail. Superseded decisions stay in history rather than being deleted.

## Evidence
Common industry practice; see the template for structure.
