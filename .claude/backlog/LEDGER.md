
## sprint run-20260914T140832Z -- ended 2026-09-14T14:42:14Z

| Figure | Estimate | Actual | Estimate source |
|---|---|---|---|
| tickets | 2 | 3 | confirmed scope @ 2026-09-14T14:42:34Z |
| wall_clock_min | no prior | 27 | MEASUREMENT.md per-skill table, recorded 2026-08-24; wall_clock no prior |
| tokens | 15992754 | 24965786 | MEASUREMENT.md per-skill table, recorded 2026-08-24; wall_clock no prior |
| usd | 15.32 | 11.39 | MEASUREMENT.md per-skill table, recorded 2026-08-24; wall_clock no prior |

GATE develop 2 ticket(s) session 207f2b31: predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped @ 2026-09-14T14:42:34Z) observed USD 0.00 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
GATE develop 2 ticket(s) session b1eb9044: predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped @ 2026-09-14T14:42:34Z) observed USD 6.07 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
GATE develop 2 ticket(s) session 7f3a9c1e: predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped @ 2026-09-14T14:42:34Z) observed USD 0.00 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
RATIO verify_usd_per_ticket batched session 78742603 = 1.39
  numerator USD 2.78 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
  denominator 2 ticket(s) (run-20260914T140832Z.jsonl outcome events @ 2026-09-14T14:42:34Z)
RATIO verify_usd_per_ticket batched session 9f5b2e7a = 0.00
  numerator USD 0.00 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
  denominator 2 ticket(s) (run-20260914T140832Z.jsonl outcome events @ 2026-09-14T14:42:34Z)
DESIGN 0003 session 85308c3f concurrent: predicted USD 2.32 (MEASUREMENT.md per-skill table, recorded 2026-08-24 @ 2026-09-14T14:42:34Z) observed USD 0.00 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
DESIGN 0003 session 18c66ada concurrent: predicted USD 2.32 (MEASUREMENT.md per-skill table, recorded 2026-08-24 @ 2026-09-14T14:42:34Z) observed USD 2.54 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
DESIGN 0003 session 00000000 concurrent: predicted USD 2.32 (MEASUREMENT.md per-skill table, recorded 2026-08-24 @ 2026-09-14T14:42:34Z) observed USD 0.00 (harvest-usage.sh over 1 session id(s) @ 2026-09-14T14:42:34Z)
FINDINGS parked 2 (run-20260914T140832Z.jsonl outcome events @ 2026-09-14T14:42:34Z)

**Attribution correction (supervisor, same turn as the record above).** The zero-USD GATE and
DESIGN rows are artefacts, not observations — ignore them when reading this row as a prior:

- `--session-id` did **not** pin the nested session's id. The CLI minted its own, so the ids this
  run dispatched with never appear in any transcript. The real ones are **b1eb9044** (develop,
  USD 6.07), **18c66ada** (design, USD 2.54), **78742603** (verify, USD 2.78). Every other session
  id in the rows above is either a dispatch that failed before starting or an id the outcome
  envelope reported for itself; all harvest to USD 0.00 because no transcript carries them.
- `predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped)` means the key is **absent**
  from `config.yml`, not that the prediction was zero. `config.yml` also lacks
  `findings_max_sprints` and `lock_stale_seconds`.
- The `tickets` actual of 3 counts the design ticket. Only **2 tickets closed** (0001, 0002);
  0003 was decided and handed to the next sprint.
- **Supervisor spend is not in the USD actual above.** Stages were USD 11.39; this supervisor was
  USD 3.38 over 34 turns, so the run was **USD 14.77** and **USD 7.39 per closed ticket**.
  Counting only the gates that close tickets, (6.07 + 2.78) / 2 = **USD 4.43 per closed ticket**.
- Two dispatches failed before starting: `--json-schema` rejected
  `skills/sprint/outcome.schema.json` because this CLI build cannot resolve its
  `$schema` draft-2020-12 ref. Stripping that one key fixed it. No stage ran, nothing was claimed.
- First wall-clock datum for this project: **27 min**. There was no prior.
