---
name: metaflow-inspect
description: Inspect a Metaflow run on Outerbounds — list steps, fetch step logs, list artifacts, read an artifact's value, or report run lineage (resume chain and/or upstream trigger). Trigger when the user names a flow plus a run id (e.g. "Gen5BMonitoringFlow/19464", "logs from run 19464", "what did `monitoring_results_df` contain in that run?", "what's the parent of run 19464?") and wants status, logs, artifact values, or lineage from past Metaflow runs.
---

# metaflow-inspect

Inspect past Metaflow runs (logs and artifacts) via the Outerbounds-configured Metaflow client. Uses the **global namespace** (all users, not just the current one). Auth comes from `~/.metaflowconfig/config.json`, which is already set up on this machine.

The skill ships one helper script that handles every operation:

```
~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py
```

(Named `metaflow_inspect.py` rather than `inspect.py` to avoid shadowing Python's stdlib `inspect` module — `uv run --script` puts the script's directory on `sys.path`.)

Invoke it via `uv run` — it declares its own dependencies via PEP 723 inline metadata, so no project setup is needed and it works from any working directory.

## Prerequisites

- **`uv` must be on `PATH`.** The script uses PEP 723 inline script metadata and is invoked via `uv run`. If `uv` is missing, every subcommand will fail with `command not found: uv`. Install with `curl -LsSf https://astral.sh/uv/install.sh | sh` (or `brew install uv`).
- **Outerbounds auth at `~/.metaflowconfig/config.json`.** Required for the Metaflow client to talk to the metadata service. If this file is missing, surface the error to the user — don't try to "fix" it.
- **AWS credentials for the configured datastore.** Run metadata and small inline artifacts (strings, ints, short lists) read fine without AWS creds, but logs and S3-backed artifacts (DataFrames, large dicts, models) require working AWS credentials that match the profile / role in your Outerbounds config. A `ProfileNotFound` or comparable error in the output means the AWS side, not Metaflow, is misconfigured.
- **No pre-install of `outerbounds` required.** On first invocation, `uv` provisions a cached venv with `outerbounds` (~30s once); subsequent invocations hit the cache instantly.

## When to invoke

Use this skill when the user:

- Names a flow + run id and asks about steps, status, timing, or whether the run succeeded.
- Asks what was logged during a specific step (stdout/stderr).
- Asks what artifacts a run produced, or wants to inspect the contents of one (a dataframe shape, a dict's keys, a config value).
- Says something like "why did `compute_drift` fail in run 19464" or "show me `monitoring_results_df` from the latest run."
- Asks about a run's **lineage / parent / origin** — e.g. "was this run resumed?", "what was this run resumed from?", "what triggered run 19464?", "what's the parent of …?", "what's upstream of …?".

If the user gives only a run id (no flow name) and the flow is unambiguous from conversation context, fill it in. Otherwise ask before running.

### Disambiguating "parent" / "lineage" questions

The word "parent" (or "upstream", or vague phrases like "where did this come from") can mean two very different things in Metaflow, and you should **ask the user to clarify before running `lineage`**:

1. **Resume / origin run** — was this run produced by `metaflow resume` from a prior run? If so, every task carries `origin-run-id` metadata pointing back to the source. This is run-level cloning, not data dependency.
2. **Upstream trigger run** — was this run triggered by another flow's completion (`@trigger_on_finish`, Argo event, etc.)? The triggering run is recorded under `Run.trigger`. This is workflow-level orchestration.

These are unrelated mechanisms — a run can be a resume of one run *and* triggered by another (or neither). Don't guess. Ask the user which they want; if they want both, use `--mode both` (the default). DAG step parents (within a single run) are a third meaning — usually answered by `status`, not `lineage`.

## How to invoke

All subcommands take a Metaflow pathspec as their first positional. `FlowName/RUN_ID` for `status` / `artifacts` / `read` / `lineage`; `FlowName/RUN_ID/step_name` for `logs`.

### `status` — list all steps and their state

```
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py status Gen5BMonitoringFlow/19464
```

Prints run-level metadata (finished, successful, created/finished timestamps, tags) followed by a markdown table of every step with state and timing.

### `logs` — stdout/stderr for a step's task

```
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py logs Gen5BMonitoringFlow/19464/compute_drift
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py logs Gen5BMonitoringFlow/19464/compute_drift --stream stderr --tail 50
```

Defaults: latest task in the step, both streams, last 200 lines per stream. Flags:
- `--task-id ID` — specific task id (use when a step has fan-out / multiple tasks).
- `--stream stdout|stderr|both` — which stream(s) to fetch (default `both`).
- `--tail N` — show only last N lines per stream (use `--tail 0` for all). Default `200`.

### `artifacts` — list every artifact each step produced

```
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py artifacts Gen5BMonitoringFlow/19464
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py artifacts Gen5BMonitoringFlow/19464 --step compute_drift
```

Lists artifact names and their Python types per step. Does **not** load values — safe to run on any run.

### `read` — load and summarize one artifact

```
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py read Gen5BMonitoringFlow/19464 monitoring_results_df
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py read Gen5BMonitoringFlow/19464 some_config --step start
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py read Gen5BMonitoringFlow/19464 small_dict --full
```

Smart summarization by type:
- `pandas.DataFrame` → shape, dtypes, `head(N)` (default `N=10`)
- `pandas.Series` → length, dtype, `head(N)`
- `dict` → key count + per-key type/length (first N keys)
- `list` / `tuple` → length + first N elements
- `str` → first 2000 chars
- scalars → printed directly
- other objects → truncated `repr()` + type info

Flags:
- `--step NAME` — restrict search to one step (if an artifact name appears in multiple steps).
- `--head N` — rows / elements / keys to show (default `10`).
- `--full` — disable truncation. Use sparingly — DataFrames can be huge.

### `lineage` — report resume chain and/or upstream trigger

```
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py lineage Gen5BMonitoringFlow/19464
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py lineage Gen5BMonitoringFlow/19464 --mode resume
uv run ~/.claude/skills/metaflow-inspect/scripts/metaflow_inspect.py lineage Gen5BMonitoringFlow/19464 --mode trigger
```

Reports two distinct kinds of lineage (see [Disambiguating "parent" / "lineage" questions](#disambiguating-parent--lineage-questions) above — ask the user which they want before running):

- **Resume lineage** (`--mode resume`): walks `origin-run-id` task metadata back through the resume chain (`run_A` → `run_B` → `…`) until it hits a fresh run. Also cross-checks every step in the target run and reports whether the resume was *uniform* (every step cloned from the same origin) or *partial* (origins differ across steps).
- **Trigger lineage** (`--mode trigger`): reads `Run.trigger` to report the upstream run(s) and event(s) that triggered this run (via `@trigger_on_finish` / event-driven orchestration). Reports "no trigger metadata" if absent.

Default mode is `both`. Use `--mode` to scope to one when you already know which the user wants.

## Output handling

The script's output is structured markdown intended for you to read and summarize for the user — **don't dump the raw output verbatim**. Pull out the relevant signal (e.g. "the run succeeded; `compute_drift` took 4 minutes; `monitoring_results_df` is a 12k×8 dataframe with these dtypes"). Only echo a code block if the user explicitly asks for raw logs or full content.

Start narrow: prefer default `--head` and `--tail` settings first. Only request `--full` or a larger `--head` if the user asks for more.

## Error handling

The script exits non-zero with a clean error message on stderr for:
- Run / step / artifact not found
- Auth failures (Outerbounds / Metaflow config issues)
- Unreadable artifacts (deserialization errors, missing S3 objects, etc.)

If you see an auth error, surface it to the user verbatim — don't try to "fix" it by guessing. The user will know whether they need to re-authenticate.

## Notes

- The script calls `namespace(None)` before every lookup, so it finds runs regardless of who launched them.
- First invocation may take ~30s while `uv` provisions a cached venv with `outerbounds`. Subsequent invocations are fast.
- Don't pipe the output through `head` / `tail` in shell — pass `--tail` / `--head` flags to the script instead so it can truncate intelligently.
