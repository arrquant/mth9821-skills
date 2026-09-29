---
name: audit
description: Turn a homework PDF and Excel blueprint into HWn/notes.md, listing every problem and every open question before any code exists. Use at the start of each assignment, e.g. /audit HW2.
argument-hint: "[HWn]"
arguments: [hw]
disable-model-invocation: true
---

# Audit $hw

Turn the PDF and blueprint in `$hw/spec/` into `$hw/notes.md`, and surface every question before any code exists.

## Rules

- Write only `$hw/notes.md`. No solution code. Never modify anything in `$hw/spec/`.
- Never mark an item decided. A new question is `Status: OPEN`; a question that matches an earlier assignment's decision is `Status: INHERITED` (steps 4 and 6). Never write `DECIDED`: only the user writes decisions.
- Quote formulas as the PDF gives them, even when they look wrong. Put the doubt in an OPEN question, not in the transcription.

## Procedure

1. **Read the PDF** in `$hw/spec/`. Read it page by page with the Read tool, which renders the pages. Subscripts, fractions and summation limits often get garbled in extracted text, so check every formula against the rendered page.

2. **Dump the blueprint**: every sheet name and every non-empty cell, with its address.
   ```sh
   .venv/bin/python - "$hw"/spec/*.xlsx <<'EOF'
   import sys, openpyxl
   for path in sys.argv[1:]:
       wb = openpyxl.load_workbook(path)
       for ws in wb.worksheets:
           print(f"== {path} :: {ws.title} ({ws.dimensions})")
           for row in ws.iter_rows():
               for c in row:
                   if c.value is not None:
                       print(f"{c.coordinate}\t{c.value!r}")
   EOF
   ```
   Formula cells show up as strings starting with `=`. Note which cells expect our outputs.

3. **Write `$hw/notes.md`** in the format below:
   - Deliverables: the cover page (members, and who wrote each problem), the filled blueprint, and anything else the PDF mentions.
   - One section per problem, with:
     - parameters;
     - formulas exactly as given;
     - the N-grid or step grid;
     - which normals the problem uses and exactly how they are indexed from the stream (which uniforms, which method, which normal feeds which path and step);
     - required outputs, and the blueprint cell range for each output.
   - Numbered INHERITED items (C1, C2, …) and numbered OPEN questions (Q1, Q2, …).

4. **Read earlier decisions** before writing any question. Read every earlier `HW*/notes.md` (every assignment numbered below $hw) and collect each item whose status is `DECIDED` or `INHERITED`, with its decision text. For an INHERITED item, trace it back to the assignment where the user decided it, and cite that original source. If a later assignment overrode a decision, the latest one wins.

5. **Look for questions** using this checklist. Check every problem against every item:
   - A given parameter that never appears in a formula that should use it, or a formula inconsistent with an analogous one in the same or an earlier assignment (compare with earlier `HW*/notes.md` if they exist).
   - Mismatches between the text and the tables: index ranges, row counts, labels.
   - Stream usage that isn't fully specified: restart at x_0 = 1 for each problem? Prefixes of one stream? How paired or multi-dimensional normals map onto the stream (interleaved or in blocks)?
   - Variable names or counts in a formula that don't match the surrounding text.
   - Definitions with a surprising consequence worth confirming.
   - Unspecified numerical choices: root-finder, tolerances, rounding, reported precision.
   - Blueprint layout that doesn't match the requested outputs.

6. **Sort each question** into INHERITED or OPEN:
   - **INHERITED:** the same question was decided earlier (step 4). The readings are the same, the earlier decision applies as written, and nothing in the new PDF or blueprint addresses it. Typical examples are reported precision, how A−R and Box–Muller consume uniforms, and the stream prefix convention.
   - **OPEN:** everything else. That includes new questions; questions that only resemble an earlier one; cases where the new spec says something relevant or changes the conditions (different method, stream layout, grid, or blueprint); and anything you're unsure matches. When an OPEN question is close to an earlier decision, cite that decision in its Recommendation.

7. **For each INHERITED item**, give:
   - its location in this assignment;
   - the earlier decision, quoted word for word;
   - its source (e.g. `HWm Qk`);
   - why it matches, in one line, including what you checked in the new spec.

   The status is INHERITED, and the `Decision (user):` line stays empty for the user.

8. **For each OPEN item**, give:
   - its location (page, problem, formula);
   - what conflicts;
   - each plausible reading;
   - the numerical consequence of each reading (compute it with your `mth9821` package when that's cheap, and label it a diagnostic);
   - your recommendation.

   The status stays OPEN.

9. **Stop.** Tell the user:
   - how many OPEN items there are, with their titles;
   - how many INHERITED items there are, with their titles and sources, and a request to review them;
   - that decisions go into `notes.md` under each OPEN item, as `Decision (user): …`;
   - that /solve applies an INHERITED item as written unless they change it. To override one, they write `Decision (user): …` under it and set `Status: DECIDED`; to reopen it, they set `Status: OPEN`.

## `notes.md` format

```markdown
# HWn notes

## Deliverables
- …

## Problems
### p1 — <title>
Parameters: …
Formulas (as given): …
Grid: …
Normals: <method>; <which stream positions feed which path/step>
Outputs → blueprint: <output> → <sheet>!<range>; …

## Carried over from earlier assignments
### C1: <short title>
- Location: …
- Earlier decision: "<quoted word for word>"
- Source: HWm Qk
- Why it matches: …
- Status: INHERITED
- Decision (user):

## Open questions
### Q1: <short title>
- Location: …
- Conflict: …
- Readings: (a) … (b) …
- Consequence: …
- Recommendation: …
- Status: OPEN
- Decision (user):

## Results
(appended by /solve)
```
