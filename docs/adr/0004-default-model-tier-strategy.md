# ADR-0004: Default model tier strategy for the enterprise copilot

- Status: provisional, pending Day 29 evals
- Date: 2026-11-22
- Deciders: repo owner

## Context
The copilot answers employee questions using retrieved company documents. Requests vary a lot: some are simple lookups or rewrites, others need multi-document reasoning with citations. Model prices differ widely between tiers, and output tokens cost more than input tokens (see the Day 2 notebook). The retrieved chunks make up roughly half of each request's input, so cost scales with traffic quickly.

What I do not know yet: how well a cheaper model answers my real questions. I have no golden dataset or evaluation harness until Day 29, so any claim that a cheaper model is good enough would be a guess.

Constraints:
- Wrong or unfaithful answers on company data are costly, so quality must be measured before cost is cut.
- The application should not need rewriting when the model choice changes.
- Prices and model versions change often, so the choice must be easy to revisit.

## Options considered
1. One strong model for every request: simplest to build and the best chance of good answers, but the highest cost, and simple requests are overpaid for.
2. One small, cheap model for every request: lowest cost and latency, but likely to fail on complex or ambiguous questions, and I could not know how often without evals.
3. A router: send easy requests to a small model and harder ones to a strong model, using rules or a classifier, with fallback to the strong model when confidence is low. It gives the best cost and quality trade-off, but it needs evals, monitoring and ongoing tuning, and a routing mistake silently lowers quality.

## Decision
Design for option 3 and roll it out in stages. Start in production with option 1 (one strong model), but behind the LLM gateway so that model choice is configuration, not application code. Enable routing only after the Day 29 evals show that the small model meets the quality bar for named request types.

The single most important reason: I cannot safely optimise cost for quality I have not measured. Starting with the strong model gives a trustworthy baseline and a reference for comparison, while the gateway abstraction keeps the cheaper options open.

## Consequences
- Easier: a quality baseline exists from day one, and switching or adding models is a configuration change.
- Harder: early cost is higher than necessary until routing is proven.
- Every request must be logged with request type, model used, tokens, latency and cost, otherwise routing decisions cannot be evaluated later.
- Routing rules start simple (for example by request type, such as classification or query rewrite) and only move to a learned classifier if rules prove too crude.
- A fallback to the strong model is required when the small model's confidence is low or a validation check fails.
- Revisit on Day 29 with eval results, and again when provider prices or model versions change materially.

## Evidence
No measurements yet. To collect: eval scores (correctness, faithfulness, citation accuracy) for each model on the golden dataset, cost per 1,000 requests from the Day 2 notebook using real prices, p95 latency per model, and the share of traffic by request type.
