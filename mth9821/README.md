# `mth9821`: your team's library

This package starts empty. Below are the functions teams usually need over the semester. Add each one when an assignment first needs it, with a test in `tests/test_lib.py`, and keep this list as your plan. `/solve` will use these functions, or add them.

Two rules apply to every function here:

- **Implement the methods yourself.** When an assignment asks you to implement a method, a library routine can't stand in for it (for example `scipy.stats.norm.ppf` in place of your inverse transform). SciPy and friends are fine in tests and cross-checks.
- **Algorithms only, no conventions.** How a problem slices the random stream (restarts, prefixes, uniforms per trial, pairing, path/step layout) is a decision recorded in that assignment's `notes.md`. Don't hard-code it here.

## `rng.py`: random numbers

| Function | What it does |
|---|---|
| `lcg_uniforms(n, x0=1)` | The first n uniforms of the linear congruential generator defined in the assignment. Use int64 arithmetic; a jump-ahead or blocked vectorization keeps millions of draws fast. |
| `bsm_inverse(u)` | Inverse standard normal CDF by Beasley–Springer–Moro (Glasserman, Figs. 2.12–2.13). Vectorized over an array. |
| `acceptance_rejection(u)` | Standard normals by acceptance–rejection with a double-exponential proposal. Returns the normals and the number of uniforms used. |
| `marsaglia_bray(u)` | Standard normals by the Marsaglia–Bray form of Box–Muller. Returns the normals and the number of uniforms used. |
| `normal_stream(n, method)` | The first n normals of one stream for a given method, cached on disk (`cache/` is git-ignored) so reruns are instant. |

## `bs.py`: Black–Scholes with continuous dividend yield q

All take `(S, K, T, r, q, sigma, kind)` with `kind` `"call"` or `"put"`, and broadcast over NumPy arrays.

| Function | What it does |
|---|---|
| `price(...)` | Black–Scholes price. |
| `delta(...)`, `gamma(...)`, `vega(...)` | Closed-form Greeks. Document the units, e.g. vega per unit σ. |
| `implied_vol(target, S, K, T, r, q, kind)` | Implied volatility. Name the root-finder, bracket and tolerance in the docstring. If an assignment asks you to implement the root-finder, that's the exercise, so don't use a library routine. |

## `exotic.py`: exotic closed forms and Monte Carlo helpers

| Function | What it does |
|---|---|
| `running_means(x, Ns)` | Means of the prefixes x[:N] for every N in a grid, from one cumulative sum. |
| Barrier-option closed forms | e.g. down-and-out and down-and-in calls, as assignments introduce them. Quote the formula and its validity conditions (such as B ≤ K) in the docstring. |

Add modules (PDE solvers, trees, linear algebra) the same way when the course reaches them.

## Tests

Test each function against something independent: `scipy.stats.norm` for the inverse CDF, put–call parity and finite differences for the Greeks, and hand-computed first values for the LCG. Run `pytest -q`. It reports "no tests ran" until you add the first test.
