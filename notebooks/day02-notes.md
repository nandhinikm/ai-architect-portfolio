# Day 2 notes: tokens, context, sampling and cost

## 1. Which input component dominates RAG request cost? Cheapest way to shrink it?
Retrieved chunks. In the default request they are 2,000 of about 4,060 input tokens (roughly half), with conversation history next at about 1,500 (roughly a third). The cheapest fix is to retrieve fewer, better chunks: tune top_k, add a re-ranker and drop low-scoring chunks, so quality is protected while tokens fall. Summarising or trimming chat history is the second lever, and caching the static system prompt is the third.

## 2. Output tokens cost several times more than input. How does that change prompt design?
Output is a per-token premium, so I design for short, structured answers: ask for concise responses, set a sensible max output limit, request JSON or bullet formats instead of free prose, and avoid asking the model to repeat the retrieved context back. Where quality allows, I use more input to get less output, such as clearer instructions and examples. I also never let the model "think out loud" for simple tasks, since that output is billed.

## 3. When to route to a small model, and what must I measure first?
Route to a small model for easy, high-volume, low-risk requests such as classification, extraction, simple lookups and query rewriting. Keep a stronger model for complex reasoning, ambiguous questions and high-stakes answers. Before routing, I must measure on a golden dataset that the small model meets the quality bar for that request type: answer correctness, faithfulness to the retrieved context, citation accuracy, refusal behaviour and latency. I also need a way to catch routing mistakes in production, such as sampled human review, user feedback and a fallback to the larger model.

## 4. Two reasons a bigger context window is not a free upgrade
1. Cost and latency: every extra token is billed, and more input means slower responses, and attention work grows faster than linearly with length.
2. Quality: models can miss or misuse details buried in a long context, and irrelevant text adds noise, so more context can lower answer accuracy. A larger window also widens the attack surface for prompt injection and raises the privacy risk of pulling in more data than needed.

## 5. Which numbers are assumptions I must verify with real traffic?
- Prices per million tokens, including the cached-input discount (placeholder values until checked against the provider's pricing page).
- Average chunk size and the real top_k used.
- Conversation history length, since real users may have long or short chats.
- Output length per answer.
- The cache hit rate (I assumed 60%) and the share of requests that a small model can handle (I assumed 70%).
- Requests per day and how many are repeat or similar questions.
- Retry and failure rates, which add hidden cost.
