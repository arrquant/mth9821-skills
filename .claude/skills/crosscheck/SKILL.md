---
name: crosscheck
description: Compare HWn/pK.py value by value with an independent reimplementation of the same problem, done from the PDF alone by a teammate (default) or by an isolated headless Claude session (XCHECK_MODEL set). Use after /solve, e.g. /crosscheck HW1 p2.
argument-hint: "[HWn] [pK]"
arguments: [hw, problem]
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_PROJECT_DIR}/scripts/crosscheck.sh *)
---

# Crosscheck $hw $problem

Compare `$hw/$problem.py` with an independent reimplementation whose author couldn't see our code, notes or decisions.

## Procedure

1. **Get the independent results:**
   ```sh
   ${CLAUDE_PROJECT_DIR}/scripts/crosscheck.sh $hw $problem
   ```
   - **Teammate mode** (default, `XCHECK_MODEL` unset). Exit 0: a teammate's `results.json` and `checker-notes.md` are already in `$hw/crosscheck/$problem/`, so go on to step 2. Exit 3: the script built a packet in `$hw/crosscheck/$problem/packet/`. Tell the user to send it to a teammate who hasn't seen this problem's code or `notes.md`, then stop. Don't read or summarize our solution for the packet, and don't write the teammate's results yourself.
   - **Model mode** (the user set `XCHECK_MODEL`). The script runs an isolated headless Claude session and copies its results into `$hw/crosscheck/$problem/`. It can take several minutes, so run it in the background and wait for it to finish.

   If the script fails, report the error and stop.

2. **Compare value by value.** Run `$hw/$problem.py`'s `solve()` and match each of its outputs to the corresponding value in `results.json`. Map the keys by meaning, and list any output that exists on only one side.
   - With a deterministic RNG, correct implementations agree to near machine precision. Tolerance: |ours − theirs| ≤ 1e-8 · max(|ours|, |theirs|), or ≤ 1e-12 when both values are near zero.
   - Report the largest relative difference for each table.

3. **Diagnose mismatches.** For each one, read the checker's `checker-notes.md` and code:
   - If the checker chose a different reading of the spec, write it up as a question for the user. Name the reading and our `notes.md` decision, and don't judge which is right.
   - If the checker used the same reading, it's a likely bug. Say where (whose code, which line or step) and why. It can be on either side.

4. **Append `### $problem` under `## Crosscheck` in `$hw/notes.md`** (create the heading if it's missing) with:
   - who checked (teammate, or the model and its run directory);
   - match or mismatch per output, with the maximum relative difference;
   - the ambiguities the checker reported that we haven't recorded;
   - your diagnosis of each mismatch.

   Don't change any code or decisions.

5. **Report** a one-line verdict (all match, or N mismatches) and the questions for the user.
