#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["outerbounds"]
# ///
"""Inspect Metaflow runs on Outerbounds: status, logs, artifacts, read, lineage.

Usage:
    inspect.py status    FlowName/run_id
    inspect.py logs      FlowName/run_id/step_name [--task-id ID] [--stream STREAM] [--tail N]
    inspect.py artifacts FlowName/run_id [--step NAME]
    inspect.py read      FlowName/run_id ARTIFACT [--step NAME] [--head N] [--full]
    inspect.py lineage   FlowName/run_id [--mode resume|trigger|both]

Assumes Outerbounds auth is configured at ~/.metaflowconfig/config.json.
"""

from __future__ import annotations

import argparse
import sys
from typing import Any

from metaflow import Run, Step, Task, namespace
from metaflow.exception import MetaflowNotFound

STR_TRUNCATE = 2000
REPR_TRUNCATE = 500


def _die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)


def _resolve_run(pathspec: str) -> Run:
    namespace(None)
    try:
        return Run(pathspec)
    except MetaflowNotFound:
        _die(f"error: no run found for pathspec '{pathspec}' in global namespace")
    except Exception as e:
        _die(f"error: failed to resolve run '{pathspec}': {type(e).__name__}: {e}")


def _resolve_step(pathspec: str) -> Step:
    namespace(None)
    try:
        return Step(pathspec)
    except MetaflowNotFound:
        _die(f"error: no step found for pathspec '{pathspec}' in global namespace")
    except Exception as e:
        _die(f"error: failed to resolve step '{pathspec}': {type(e).__name__}: {e}")


def _pick_task(step: Step, task_id: str | None) -> Task:
    tasks = list(step.tasks())
    if not tasks:
        _die(f"error: step '{step.pathspec}' has no tasks")
    if task_id is None:
        return tasks[-1]
    for t in tasks:
        if t.id == task_id or t.pathspec.endswith(f"/{task_id}"):
            return t
    _die(f"error: task '{task_id}' not found in step '{step.pathspec}'")


def _fmt_time(ts: Any) -> str:
    if ts is None:
        return "-"
    try:
        return ts.strftime("%Y-%m-%d %H:%M:%S")
    except AttributeError:
        return str(ts)


def cmd_status(args: argparse.Namespace) -> None:
    run = _resolve_run(args.pathspec)
    print(f"# Run {run.pathspec}")
    print()
    print(f"- finished:   {run.finished}")
    print(f"- successful: {run.successful}")
    print(f"- created:    {_fmt_time(run.created_at)}")
    print(f"- finished_at:{_fmt_time(run.finished_at)}")
    try:
        tags = sorted(run.tags)
        if tags:
            print(f"- tags:       {', '.join(tags)}")
    except Exception:
        pass
    print()
    print("| step | finished | successful | tasks | started | ended |")
    print("|------|----------|------------|-------|---------|-------|")
    for step in run.steps():
        try:
            tasks = list(step.tasks())
            n_tasks = len(tasks)
            first = tasks[-1] if tasks else None
            started = _fmt_time(first.created_at) if first else "-"
            ended = _fmt_time(first.finished_at) if first else "-"
            finished = first.finished if first else False
            successful = first.successful if first else False
        except Exception as e:
            n_tasks = 0
            started = ended = "-"
            finished = successful = False
            print(f"| {step.id} | ERROR | {type(e).__name__} | - | - | - |")
            continue
        print(
            f"| {step.id} | {finished} | {successful} | {n_tasks} | {started} | {ended} |"
        )


def _print_log(label: str, content: str, tail: int | None) -> None:
    if not content:
        print(f"## {label}\n\n_(empty)_\n")
        return
    lines = content.splitlines()
    truncated = False
    if tail is not None and len(lines) > tail:
        lines = lines[-tail:]
        truncated = True
    print(f"## {label}")
    if truncated:
        print(f"_(showing last {tail} of {len(content.splitlines())} lines)_")
    print()
    print("```")
    print("\n".join(lines))
    print("```")
    print()


def cmd_logs(args: argparse.Namespace) -> None:
    step = _resolve_step(args.pathspec)
    task = _pick_task(step, args.task_id)
    print(f"# Logs for {task.pathspec}")
    print()
    streams = ("stdout", "stderr") if args.stream == "both" else (args.stream,)
    for s in streams:
        try:
            content = getattr(task, s) or ""
        except Exception as e:
            print(f"## {s}\n\n_(failed to fetch: {type(e).__name__}: {e})_\n")
            continue
        _print_log(s, content, args.tail)


def _type_label(value: Any) -> str:
    t = type(value)
    mod = t.__module__
    return f"{mod}.{t.__name__}" if mod and mod != "builtins" else t.__name__


def cmd_artifacts(args: argparse.Namespace) -> None:
    run = _resolve_run(args.pathspec)
    print(f"# Artifacts for {run.pathspec}")
    print()
    target_steps = [args.step] if args.step else None
    for step in run.steps():
        if target_steps and step.id not in target_steps:
            continue
        tasks = list(step.tasks())
        if not tasks:
            continue
        task = tasks[-1]
        artifacts = list(task.artifacts)
        if not artifacts:
            continue
        print(f"## step `{step.id}` ({task.pathspec})")
        print()
        print("| name | type |")
        print("|------|------|")
        for art in sorted(artifacts, key=lambda a: a.id):
            try:
                tname = _type_label(art.data)
            except Exception as e:
                tname = f"<unreadable: {type(e).__name__}>"
            print(f"| {art.id} | {tname} |")
        print()


def _summarize_value(value: Any, head: int, full: bool) -> str:
    type_label = _type_label(value)
    out: list[str] = [f"type: `{type_label}`"]

    try:
        import pandas as pd
    except ImportError:
        pd = None

    if pd is not None and isinstance(value, pd.DataFrame):
        out.append(f"shape: {value.shape}")
        out.append("\ndtypes:")
        out.append("```")
        out.append(str(value.dtypes))
        out.append("```")
        out.append(f"\nhead({head}):")
        out.append("```")
        out.append(value.head(head).to_string() if not full else value.to_string())
        out.append("```")
        return "\n".join(out)

    if pd is not None and isinstance(value, pd.Series):
        out.append(f"length: {len(value)}, dtype: {value.dtype}")
        out.append(f"\nhead({head}):")
        out.append("```")
        out.append(value.head(head).to_string() if not full else value.to_string())
        out.append("```")
        return "\n".join(out)

    if isinstance(value, dict):
        out.append(f"keys: {len(value)}")
        out.append("\n| key | type | length/repr |")
        out.append("|-----|------|-------------|")
        for k, v in list(value.items())[: None if full else head]:
            tlabel = _type_label(v)
            try:
                size = len(v)  # type: ignore[arg-type]
                detail = f"len={size}"
            except TypeError:
                r = repr(v)
                detail = r if len(r) <= 80 else r[:77] + "..."
            out.append(f"| `{k}` | {tlabel} | {detail} |")
        if not full and len(value) > head:
            out.append(f"\n_({len(value) - head} more keys not shown — pass --full)_")
        return "\n".join(out)

    if isinstance(value, (list, tuple)):
        out.append(f"length: {len(value)}")
        sample = value if full else value[:head]
        out.append(f"\nfirst {len(sample)} element(s):")
        out.append("```")
        for i, item in enumerate(sample):
            r = repr(item)
            if len(r) > REPR_TRUNCATE:
                r = r[:REPR_TRUNCATE] + f"... (+{len(repr(item)) - REPR_TRUNCATE} chars)"
            out.append(f"[{i}] ({_type_label(item)}) {r}")
        out.append("```")
        if not full and len(value) > head:
            out.append(f"_({len(value) - head} more elements not shown — pass --full)_")
        return "\n".join(out)

    if isinstance(value, str):
        out.append(f"length: {len(value)} chars")
        out.append("\n```")
        if not full and len(value) > STR_TRUNCATE:
            out.append(value[:STR_TRUNCATE])
            out.append(f"\n... ({len(value) - STR_TRUNCATE} more chars — pass --full)")
        else:
            out.append(value)
        out.append("```")
        return "\n".join(out)

    if isinstance(value, (int, float, bool)) or value is None:
        out.append(f"value: `{value!r}`")
        return "\n".join(out)

    r = repr(value)
    if not full and len(r) > REPR_TRUNCATE:
        r = r[:REPR_TRUNCATE] + f"... (+{len(repr(value)) - REPR_TRUNCATE} chars — pass --full)"
    out.append("\nrepr:")
    out.append("```")
    out.append(r)
    out.append("```")
    return "\n".join(out)


def _origin_for_task(task: Task) -> tuple[str | None, str | None]:
    def _clean(v: Any) -> str | None:
        if v is None:
            return None
        s = str(v)
        return None if s in ("", "None") else s

    origin_run = origin_task = None
    try:
        for m in task.metadata:
            if m.name == "origin-run-id":
                origin_run = _clean(m.value)
            elif m.name == "origin-task-id":
                origin_task = _clean(m.value)
    except Exception:
        pass
    return origin_run, origin_task


def _origin_for_run_start(flow_name: str, run_id: str) -> tuple[str | None, str | None]:
    try:
        namespace(None)
        tasks = list(Step(f"{flow_name}/{run_id}/start").tasks())
        if not tasks:
            return None, None
        return _origin_for_task(tasks[-1])
    except Exception:
        return None, None


def cmd_lineage(args: argparse.Namespace) -> None:
    run = _resolve_run(args.pathspec)
    flow_name = run.pathspec.split("/", 1)[0]
    print(f"# Lineage for {run.pathspec}")
    print()

    mode = args.mode
    if mode in ("resume", "both"):
        _report_resume_lineage(run, flow_name)
        if mode == "both":
            print()
    if mode in ("trigger", "both"):
        _report_trigger_lineage(run)


def _report_resume_lineage(run: Run, flow_name: str) -> None:
    print("## Resume lineage")
    print()

    chain: list[tuple[str, str | None, str | None]] = []
    rid: str | None = run.id
    seen: set[str] = set()
    while rid and rid not in seen:
        seen.add(rid)
        o_run, o_task = _origin_for_run_start(flow_name, rid)
        chain.append((rid, o_run, o_task))
        rid = o_run

    if len(chain) == 1 and chain[0][1] is None:
        print(f"_{run.pathspec} is a fresh run (not a resume)._")
        return

    print("| run | origin-run-id | origin-task-id (start) |")
    print("|-----|---------------|------------------------|")
    for r, o_run, o_task in chain:
        print(f"| `{flow_name}/{r}` | {o_run or '_(fresh)_'} | {o_task or '-'} |")

    print()
    print("### Per-step origin (detect partial resume)")
    print()
    by_step: list[tuple[str, str | None, str | None]] = []
    for step in run.steps():
        tasks = list(step.tasks())
        if not tasks:
            continue
        o_run, o_task = _origin_for_task(tasks[-1])
        by_step.append((step.id, o_run, o_task))

    distinct = {o for _, o, _ in by_step if o is not None}
    has_fresh = any(o is None for _, o, _ in by_step)

    if not distinct:
        print("_All steps appear freshly executed (no origin metadata)._")
    elif len(distinct) == 1 and not has_fresh:
        only = next(iter(distinct))
        print(f"_Uniform resume: every step was cloned from `{flow_name}/{only}`._")
    else:
        print("_Partial resume — origins differ across steps:_")
        print()
        print("| step | origin-run-id | origin-task-id |")
        print("|------|---------------|----------------|")
        for step_id, o_run, o_task in by_step:
            print(f"| {step_id} | {o_run or '_(fresh)_'} | {o_task or '-'} |")


def _report_trigger_lineage(run: Run) -> None:
    print("## Trigger lineage")
    print()
    try:
        trigger = getattr(run, "trigger", None)
    except Exception as e:
        print(f"_Could not read trigger metadata: {type(e).__name__}: {e}_")
        return
    if trigger is None:
        print("_No trigger metadata on this run (not triggered by an upstream flow / event)._")
        return

    upstream: list[str] = []
    runs_attr = getattr(trigger, "runs", None)
    if runs_attr:
        for r in runs_attr:
            upstream.append(getattr(r, "pathspec", None) or repr(r))
    if not upstream:
        run_attr = getattr(trigger, "run", None)
        if run_attr is not None:
            upstream.append(getattr(run_attr, "pathspec", None) or repr(run_attr))

    events = list(getattr(trigger, "events", None) or [])

    if upstream:
        print("Upstream triggering run(s):")
        print()
        for p in upstream:
            print(f"- `{p}`")
        print()
    if events:
        print(f"Triggering event(s) ({len(events)}):")
        print()
        for ev in events:
            name = getattr(ev, "name", None) or getattr(ev, "type", None) or repr(ev)
            ts = getattr(ev, "timestamp", None) or getattr(ev, "id", None)
            print(f"- `{name}` (id/ts: {ts})")
        print()
    if not upstream and not events:
        print("_Trigger object present but exposes no recognizable upstream runs or events._")
        print(f"_Raw repr: `{trigger!r}`_")


def cmd_read(args: argparse.Namespace) -> None:
    run = _resolve_run(args.pathspec)
    found: list[tuple[str, Any]] = []
    for step in run.steps():
        if args.step and step.id != args.step:
            continue
        tasks = list(step.tasks())
        if not tasks:
            continue
        task = tasks[-1]
        try:
            artifact = task[args.artifact]
        except KeyError:
            continue
        except Exception as e:
            _die(f"error: failed to access artifact '{args.artifact}' in step '{step.id}': {type(e).__name__}: {e}")
        found.append((step.id, artifact))

    if not found:
        scope = f"step '{args.step}'" if args.step else "any step"
        _die(f"error: artifact '{args.artifact}' not found in {scope} of {run.pathspec}")

    if len(found) > 1 and not args.step:
        steps = ", ".join(s for s, _ in found)
        print(
            f"# Artifact `{args.artifact}` found in multiple steps: {steps}",
            file=sys.stderr,
        )
        print(f"_(reading from last occurrence: '{found[-1][0]}' — pass --step to target a specific one)_\n", file=sys.stderr)

    step_id, artifact = found[-1]
    print(f"# {args.artifact} (step `{step_id}`, run {run.pathspec})\n")
    try:
        value = artifact.data
    except Exception as e:
        _die(f"error: failed to load artifact value: {type(e).__name__}: {e}")
    print(_summarize_value(value, head=args.head, full=args.full))


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="metaflow-inspect",
        description="Inspect a Metaflow run on Outerbounds (global namespace).",
    )
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("status", help="List steps and their state for a run.")
    s.add_argument("pathspec", help="FlowName/run_id")
    s.set_defaults(func=cmd_status)

    s = sub.add_parser("logs", help="Fetch stdout/stderr logs for a step's task.")
    s.add_argument("pathspec", help="FlowName/run_id/step_name")
    s.add_argument("--task-id", default=None, help="Specific task id (default: latest task in the step).")
    s.add_argument(
        "--stream",
        choices=("stdout", "stderr", "both"),
        default="both",
        help="Which stream(s) to fetch (default: both).",
    )
    s.add_argument("--tail", type=int, default=200, help="Show only the last N lines per stream (default: 200, 0 for all).")
    s.set_defaults(func=cmd_logs)

    s = sub.add_parser("artifacts", help="List artifacts produced by each step.")
    s.add_argument("pathspec", help="FlowName/run_id")
    s.add_argument("--step", default=None, help="Limit to one step name.")
    s.set_defaults(func=cmd_artifacts)

    s = sub.add_parser(
        "lineage",
        help="Report resume chain (origin-run-id) and/or upstream trigger lineage for a run.",
    )
    s.add_argument("pathspec", help="FlowName/run_id")
    s.add_argument(
        "--mode",
        choices=("resume", "trigger", "both"),
        default="both",
        help="Which lineage to report (default: both).",
    )
    s.set_defaults(func=cmd_lineage)

    s = sub.add_parser("read", help="Read and summarize one artifact's value.")
    s.add_argument("pathspec", help="FlowName/run_id")
    s.add_argument("artifact", help="Artifact name (e.g. 'monitoring_results_df').")
    s.add_argument("--step", default=None, help="Restrict search to one step.")
    s.add_argument("--head", type=int, default=10, help="Rows / elements to show (default: 10).")
    s.add_argument("--full", action="store_true", help="Print the full value (no truncation).")
    s.set_defaults(func=cmd_read)

    return p


def main(argv: list[str] | None = None) -> None:
    args = build_parser().parse_args(argv)
    if getattr(args, "tail", None) == 0:
        args.tail = None
    args.func(args)


if __name__ == "__main__":
    main()
