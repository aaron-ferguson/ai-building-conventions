
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

## sprint run-20260914T144927Z -- ended 2026-09-26T00:25:45Z

| Figure | Estimate | Actual | Estimate source |
|---|---|---|---|
| tickets | 4 | 4 | confirmed scope @ 2026-09-26T00:39:17Z |
| wall_clock_min | 36 | 16261 | LEDGER.md 1 recorded sprint(s) over 3 ticket(s) @ 2026-09-14T14:50:14Z |
| tokens | 33287715 | 59531421 | LEDGER.md 1 recorded sprint(s) over 3 ticket(s) @ 2026-09-14T14:50:14Z |
| usd | 15.19 | 27.22 | LEDGER.md 1 recorded sprint(s) over 3 ticket(s) @ 2026-09-14T14:50:14Z |

GATE develop 4 ticket(s) session 40e6a993: predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped @ 2026-09-26T00:39:17Z) observed USD 11.95 (harvest-usage.sh over 1 session id(s) @ 2026-09-26T00:39:17Z)
GATE develop 1 ticket(s) session 9a6983ab: predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped @ 2026-09-26T00:39:17Z) observed USD 4.41 (harvest-usage.sh over 1 session id(s) @ 2026-09-26T00:39:17Z)
GATE develop 1 ticket(s) session (see dev4_uuid): predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped @ 2026-09-26T00:39:17Z) observed USD 0.00 (harvest-usage.sh over 1 session id(s) @ 2026-09-26T00:39:17Z)
RATIO verify_usd_per_ticket batched session 519bc218 = 0.38
  numerator USD 1.52 (harvest-usage.sh over 1 session id(s) @ 2026-09-26T00:39:17Z)
  denominator 4 ticket(s) (run-20260914T144927Z.jsonl outcome events @ 2026-09-26T00:39:17Z)
RATIO verify_usd_per_ticket batched session 68a45846 = 1.30
  numerator USD 5.20 (harvest-usage.sh over 1 session id(s) @ 2026-09-26T00:39:17Z)
  denominator 4 ticket(s) (run-20260914T144927Z.jsonl outcome events @ 2026-09-26T00:39:17Z)
FINDINGS parked 4 (run-20260914T144927Z.jsonl outcome events @ 2026-09-26T00:39:17Z)

**Attribution correction (supervisor, same turn as the record above).** Four figures above are
artefacts of how they were derived, not observations. Read the row with these:

- **`wall_clock_min` 16261 is NOT work time.** It is the span from the first to the last run-log
  event, and this run's supervising conversation was paused across ~11 days of real time. **Summed
  stage wall-clock was 101 min**: develop gate 57.6, develop 0004 re-run 8.7, verify attempt 1 7.4,
  verify attempt 2 14.9, retro 12.1. Use 101, not 16261, as the prior — the span figure would tell
  the next sprint a four-ticket gate takes eleven days.
- **`predicted USD 0.00 (config.yml stage_budget_usd, as at unstamped)` means the key is still
  ABSENT** from `config.yml`, not that the prediction was zero. `findings_max_sprints` and
  `lock_stale_seconds` are still absent too — flagged in the previous sprint's correction and
  still unfixed, so `./next --findings` reports the count half of the gate only.
- **The third GATE row is a duplicate, not a third develop session.** `session (see dev4_uuid)` is
  a placeholder string the supervisor wrote into an escalation event before the id was resolved;
  the real session is `9a6983ab` at USD 4.41, already on the row above it. Two develop sessions
  ran, not three.
- **`FINDINGS parked 4` undercounts.** The outcome envelopes it sums were mostly unusable (below),
  so the figure is only what got reported. `FINDINGS.md` went from 5 entries to 12 and was drained
  by the retro to 8 tools-repo-bound entries, with 5 backlog items filed from the rest.
- **Supervisor spend is not in the USD actual above.** Stages were USD 27.22; this supervisor was
  **USD 8.17 over 57 turns**, so the run was **USD 35.39** and **USD 8.85 per closed ticket**.
  Counting only the gates that close tickets, (11.95 + 4.41 + 1.52 + 5.20) / 4 = **USD 5.77**.
- **USD 1.52 of that bought nothing.** Verify attempt 1 (`519bc218`) returned a PASS report and
  performed no backlog action at all: no claim, no evidence, no close, no commit. Cause was the
  supervisor's own dispatch prompt over-constraining output ("a SINGLE JSON object and NOTHING
  else"), which crowded out the stage's actual job. Attempt 2 (`68a45846`, USD 5.20) did the work.
- **Turn budget: 57 supervisor turns over 6 cycles is ~9.5 per cycle against a budget of 3 — OVER.**
  Roughly half were the boundary status reports the owner asked for mid-run and the ~11-day
  re-validation, both of which the owner wanted; the rest is the schema failures below forcing a
  disk read to establish what each stage had actually done.
- **`--json-schema` did not enforce on 3 of 4 stage dispatches** (prose, valid-JSON-wrong-shape,
  prose). `--session-id` DID pin correctly this run, unlike the previous sprint's experience, so
  every session harvested cleanly. Verdicts were read from the backlog instead, per the skill's own
  "the backlog *is* the state".
