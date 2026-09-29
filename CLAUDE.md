# MTH9821 homework

Weekly group homework for MTH9821, Numerical Methods for Finance (Baruch MFE).
Each assignment is a PDF plus an Excel blueprint in `HWn/spec/`; the filled copy of the blueprint is the deliverable.

## Workflow

The user runs each step and reviews between steps:

- `/audit HWn`: writes `HWn/notes.md` (problems, stream usage, numbered OPEN questions, and INHERITED items that match a decision from an earlier assignment), then stops.
- The user writes decisions into `notes.md` and reviews the INHERITED items. /solve applies an INHERITED item as written unless the user overrides it (`Status: DECIDED`) or reopens it (`Status: OPEN`).
- `/solve HWn pK`: writes `HWn/pK.py`, runs and verifies it, appends results to `notes.md`, updates the notebook.
- `/crosscheck HWn pK`: compares with an independent reimplementation from the PDF only, done by a teammate (default) or an isolated model run (`XCHECK_MODEL`).

## Random numbers

- The generators (LCG, inverse transform, acceptance-rejection, Box-Muller) are defined in the assignment PDFs; `.claude/skills/crosscheck/rng-notes.md` transcribes them.
- How a problem uses the stream (restarts, prefixes, uniforms per trial, pairing, which normal feeds which path and step) is decided in `notes.md`, never assumed here.

## Rules

- Never edit anything in `HWn/spec/`. It is the source of truth; it is read-only.
- When the spec is ambiguous or inconsistent, record it in `notes.md` as OPEN and stop (at audit time, a question that matches a user decision from an earlier assignment is recorded as INHERITED instead). Never choose a reading yourself, because a silent choice is how wrong answers get submitted.
- Follow decisions in `notes.md` exactly. The user made them with context you may not have.
- Never use a library routine for a method the assignment asks us to implement. Implementing it is the exercise; library routines are only for cross-checks and tests.
- Run code before calling it done. Unrun code has hidden bugs.
- An error that doesn't shrink as N grows, or as the time step shrinks, is a bug until the user says otherwise. Never explain it away as noise.
- Risk-neutral log drift is r − q − σ²/2. A formula that leaves out a parameter the assignment gives is an audit flag. Don't silently follow it or fix it.
- Vectorize with NumPy; no per-path Python loops at millions of samples. Running means come from one cumulative sum. Slow code discourages re-running.

## Environment

- `source .venv/bin/activate` (Python ≥ 3.12; `pip install -e '.[dev]'`).
- Tests: `pytest -q`.
- Notebooks: `jupyter nbconvert --to notebook --execute --inplace HWn/hwn.ipynb`.
- Library: `mth9821/` starts empty; `mth9821/README.md` lists the planned functions. Add each one, with tests in `tests/test_lib.py`, when an assignment first needs it.
