# metaflow-inspect Skill

A Claude Code skill for quickly inspecting Metaflow runs on Outerbounds without leaving the Claude interface.

## What it does

This skill lets you ask Claude about past Metaflow runs — their logs, outputs, status, and relationships — without manually logging into Outerbounds or writing CLI commands. Just describe what you want to know, and Claude will fetch it for you.

### Common use cases

- **"Show me the logs from the `compute_drift` step in Gen5BMonitoringFlow/19464"** → fetches stdout/stderr from that step
- **"What artifacts did run 19464 produce?"** → lists all outputs by step
- **"What's in the `monitoring_results_df` artifact from that run?"** → loads and summarizes the dataframe
- **"Was run 19464 resumed from an earlier run?"** → traces the resume chain
- **"Why did my flow fail?"** → gets the step status and relevant error logs
- **"Show me the first 50 lines of stderr from step X"** → controlled log fetching with specific ranges

## How to use it

Just mention a Metaflow flow and run ID in your message to Claude, and describe what you want to know. Examples:

```
"Show me the status of Gen5BMonitoringFlow/19464"
"What did run 19464 log during the compute_drift step?"
"What's the shape of monitoring_results_df from Gen5BMonitoringFlow/19464?"
"Was this run resumed from an earlier run?"
```

The skill automatically detects these patterns and runs the appropriate inspection command.

## What the skill can inspect

### Run status & metadata
- Whether a run succeeded or failed
- Which steps ran and their duration
- When the run started and finished
- Tags and other metadata

### Step logs
- stdout and stderr from individual steps
- Configurable range (first/last N lines)
- Filtered by stream (stdout, stderr, or both)

### Artifacts
- List all artifacts produced by a run
- Load and summarize artifact contents:
  - DataFrames (shape, dtypes, sample rows)
  - Dicts (key count, types)
  - Lists/tuples (length, elements)
  - Strings, numbers, and other types
- Control verbosity (preview vs. full contents)

### Run lineage
- **Resume chain** — was this run cloned from an earlier run? Traces all the way back.
- **Upstream triggers** — what flow triggered this run to start?

## Prerequisites

You only need these once on your machine:

- **`uv` installed** — install with `brew install uv` or `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Outerbounds config** — should already be set up at `~/.metaflowconfig/config.json` if you've used Metaflow before
- **AWS credentials** — needed if you want to inspect large artifacts stored in S3 (DataFrames, models, etc.)

The skill handles the rest automatically — it provisions dependencies on first use (~30s) and caches them for speed on subsequent calls.

## Common questions

**Can I inspect runs from other team members?**  
Yes — the skill accesses the global namespace and can inspect any run in Outerbounds.

**What if I only have a run ID, no flow name?**  
If the flow is clear from conversation context, Claude will fill it in. Otherwise it'll ask you to specify the flow.

**Can I see raw/full logs instead of a summary?**  
Yes, just ask Claude to show you the full content or more lines. You control the verbosity.

**What if my AWS credentials don't work?**  
The skill will surface the error — you can then update your AWS profile or credentials and try again.

**How is this different from logging into Outerbounds directly?**  
It's faster for quick lookups. Instead of navigating the Outerbounds UI, you just ask Claude a question in natural language and get a focused answer. Use it for debugging and exploration; use the Outerbounds UI for deeper analysis or bulk operations.

## Technical details

For implementation details, prerequisites, and advanced usage (custom tail lengths, specific step targeting), see [SKILL.md](./SKILL.md).
