---
name: solve
description: Implement, run, and verify one homework problem (HWn/pK.py) following the decisions in HWn/notes.md, then add it to the notebook. Use after /audit questions are decided, e.g. /solve HW1 p2.
argument-hint: "[HWn] [pK]"
arguments: [hw, problem]
disable-model-invocation: true
---

# Solve $hw $problem

Implement, run, and verify problem `$problem` of `$hw`.

## Rules

- Touch only `$hw/$problem.py`, this problem's part of the notebook, and this problem's Results section in `$hw/notes.md`. Library additions go in `mth9821/`, with tests.
- Follow the decisions in `$hw/notes.md` exactly, including INHERITED ones.
- If you meet a new ambiguity, add it to the Open questions in `notes.md` as OPEN (same format as the others) and stop. Don't pick a reading.
- Never use a library routine for a method the assignment asks us to implement.
- A surprise is a concern to report, never "expected", unless the user agrees.

## Procedure

1. **Check that you can proceed.** Read `$hw/notes.md`, including "Carried over from earlier assignments". An item counts as decided if it is `DECIDED`, or if it is `INHERITED` (apply its "Earlier decision" as written). A `Decision (user):` the user wrote under an item always wins over the inherited text. If any item that affects `$problem` is still OPEN, or has no decision, stop and list those items.

2. **Write `$hw/$problem.py`:**
   - `PARAMS`: a dict of every parameter.
   - `solve()`: returns pandas DataFrames shaped exactly like the blueprint tables (same rows, columns and order), as a dict keyed by table name.
   - A `__main__` block that prints every table at full precision.

   Use your `mth9821` package (planned functions are listed in `mth9821/README.md`). If the problem needs a function that is listed there, or is clearly reusable, and it doesn't exist yet, add it to `mth9821/` with a test in `tests/test_lib.py`. Index the stream exactly as `notes.md` specifies. Vectorize: no per-path Python loops, and running means over an N-grid come from one cumulative sum.

3. **Run it** with `.venv/bin/python $hw/$problem.py`, and fix any errors. If you changed `mth9821/`, also run `.venv/bin/pytest -q`.

4. **Verify, then append `### $problem` under `## Results` in `notes.md`** with:
   - **Benchmarks:** the closed form or reference value, our error, the Monte Carlo standard error, and how many SEs apart they are.
   - **Convergence:**
     - Plain Monte Carlo: sqrt(N)·|error| should be roughly flat.
     - Variance reduction: errors and SEs should be smaller than plain Monte Carlo at the same N.
     - Discretization: bias should shrink as the time step shrinks.

     An error that doesn't shrink is a bug until the user says otherwise.
   - **Sanity:** parity, no-arbitrage bounds, Greek signs, payoff lower bounds, as applicable.
   - **Concerns:** anything surprising, stated plainly.

5. **Notebook.** In `$hw/<hw lowercase>.ipynb` (create it if missing):
   - Add a section that imports `$problem`, calls `solve()`, and displays the tables.
   - The notebook's last cell fills the blueprint: copy `$hw/spec/<blueprint>.xlsx` to `$hw/<blueprint stem>-solution.xlsx`, write each output into the cells listed in `notes.md`, then re-open the copy and print those cells to confirm. Add this problem's cells to it.
   - Execute it:
     ```sh
     .venv/bin/jupyter nbconvert --to notebook --execute --inplace $hw/<hw lowercase>.ipynb
     ```
     Fix any errors.

6. **Report:** a summary of the Results section, and any concerns.
