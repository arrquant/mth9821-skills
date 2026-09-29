# mth9821-skills

A Claude Code setup for the weekly MTH9821 (Numerical Methods for Finance) homework. It gives you three manual commands: `/audit`, `/solve` and `/crosscheck`. Claude uses them to read the assignment, implement and verify each problem, and compare against an independent solution. Every judgment call about what the assignment means stays with you.

This is a template. Copy it once per team, and grow your own `mth9821/` library in it over the semester.

## Prerequisites

- [Claude Code](https://docs.claude.com/en/docs/claude-code), logged in.
- Python 3.12 or newer. If NumPy or SciPy wheels aren't available yet for the newest Python, use 3.12.
- Git.
- Optional: model-mode crosscheck needs macOS or Linux, because it runs the checker in an OS sandbox.

## Setup

```sh
git clone <your team's copy of this template> mth9821-hw && cd mth9821-hw
python3 -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
claude
```

`mth9821/` starts empty. `mth9821/README.md` lists the functions you'll need; `/solve` adds them with tests the first time a problem needs them. Review that code as carefully as a problem's code.

## Each week

Put the assignment in place and make it read-only:

```sh
mkdir -p HW3/spec
cp ~/Downloads/hw3*.pdf ~/Downloads/hw3*-blueprint.xlsx HW3/spec/
chmod a-w HW3/spec/*
```

Then three commands, with your review between them:

1. **`/audit HW3`**: Claude reads the PDF page by page and dumps the blueprint. It then writes `HW3/notes.md`: each problem's parameters, the formulas as printed, grids, exactly how the random numbers are used, and which blueprint cells each output goes to. It ends with numbered **OPEN questions**: every ambiguity, inconsistency or unspecified choice it found, with the plausible readings, the numerical consequence of each, and a recommendation. Questions you already decided in an earlier assignment show up as **INHERITED**, quoting your earlier decision.

   → **You decide.** Under each OPEN question, write `Decision (user): …` and set `Status: DECIDED`. Check the INHERITED items too: set `Status: DECIDED` with a new decision to override one, or `Status: OPEN` to reopen it.

2. **`/solve HW3 p1`** (then p2, …): writes `HW3/p1.py`, runs it, and verifies it against closed forms, standard errors, convergence rates and sanity checks (parity, bounds, signs). It appends the results and any concerns to `notes.md`, adds the problem to the notebook, and fills a copy of the blueprint, re-reading every cell to confirm. It refuses to start while an OPEN question affecting the problem is undecided. If it meets a new ambiguity, it adds it as OPEN and stops.

3. **`/crosscheck HW3 p1`**: compares your numbers value by value with an independent implementation written from the PDF alone.
   - **Default, teammate mode:** the first run builds a packet in `HW3/crosscheck/p1/packet/`: the PDF, the RNG notes and a brief. Give it to a teammate who hasn't seen that problem's code or notes. They put `results.json` and `checker-notes.md` in `HW3/crosscheck/p1/`, and you run `/crosscheck HW3 p1` again.
   - **Model mode:** `XCHECK_MODEL=opus claude`, then `/crosscheck HW3 p1`. The problem is reimplemented by a headless Claude session sandboxed away from your repo, so it can't see your code or decisions.

   With a deterministic RNG, correct implementations agree to about machine precision, so any mismatch means something. Either the two sides read the spec differently, in which case it's a question for you, or one side has a bug.

The notebook (`HW3/hw3.ipynb`) and the filled blueprint (`HW3/<blueprint>-solution.xlsx`) are the deliverables, along with the cover page the assignment asks for.

## Why the decisions stay with you

Assignments contain real ambiguities: a formula with a parameter missing, an index that runs past the array, a table whose labels don't match the text, a random-number convention that is never stated. Each has two or more defensible readings, and they give different numbers. A tool that quietly picks one produces a clean-looking answer that may be wrong, and nothing in the output tells you a choice was made. So Claude's job here is to find every such question, show you what each reading does to the numbers, and then follow your decision exactly. Your job is to decide, since you know the lectures, the TA's announcements and what the course expects. Your group signs the homework, and deciding these questions is where much of the learning happens.

For the same reasons:

- **`HWn/spec/` is read-only.** The PDF and blueprint are the source of truth. Solutions go in a copy of the blueprint.
- **Methods the assignment asks for are implemented, not imported.** Library routines are only for checks.
- **An error that doesn't shrink as N grows is a bug** until you decide otherwise.
- **The commands are manual.** Claude never runs `/audit`, `/solve` or `/crosscheck` on its own.

## Layout

```
CLAUDE.md                     rules Claude follows in this repo
.claude/skills/audit/         /audit
.claude/skills/solve/         /solve
.claude/skills/crosscheck/    /crosscheck, checker prompt, RNG notes
scripts/crosscheck.sh         builds the teammate packet or runs the isolated model check
mth9821/                      your team's library (starts empty; see its README)
tests/                        tests for mth9821/
HWn/spec/                     assignment PDF + blueprint (read-only; you add these)
HWn/notes.md                  audit, decisions, results, crosschecks
HWn/pK.py, HWn/hwn.ipynb      solutions and notebook
```
