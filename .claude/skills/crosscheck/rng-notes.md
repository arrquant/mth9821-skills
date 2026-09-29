# Random number generation notes

These are the algorithm definitions used throughout the course. They are transcribed from the assignment PDFs and Glasserman. How a problem uses the stream, including how many uniforms a rejected trial consumes, is defined by the assignment PDF and decided in `notes.md`, not here.

## Linear congruential generator

x_{i+1} = (a·x_i + c) mod k,  u_{i+1} = x_{i+1} / k, with x_0 = 1, a = 39373, c = 0, k = 2^31 − 1.

## Inverse transform: Beasley-Springer-Moro (Glasserman, Figures 2.12–2.13, p. 68)

a0..a3 = 2.50662823884, −18.61500062529, 41.39119773534, −25.44106049637
b0..b3 = −8.47351093090, 23.08336743743, −21.06224101826, 3.13082909833
c0..c8 = 0.3374754822726147, 0.9761690190917186, 0.1607979714918209, 0.0276438810333863, 0.0038405729373609, 0.0003951896511919, 0.0000321767881768, 0.0000002888167364, 0.0000003960315187

y = u − 0.5.
- If |y| < 0.42: r = y², x = y·(a0 + a1 r + a2 r² + a3 r³) / (1 + b0 r + b1 r² + b2 r³ + b3 r⁴).
- Else: r = u if y < 0, otherwise r = 1 − u; r = ln(−ln r); x = c0 + c1 r + … + c8 r⁸; if y < 0, x = −x.

## Acceptance-rejection

This uses a double-exponential proposal with c = sqrt(2e/π).

1. Take u1, u2, u3.
2. X = −ln(u1).
3. If u2 > exp(−(X − 1)²/2), reject and go to step 1.
4. Otherwise, if u3 ≤ 0.5, X = −X. Return X.

## Box-Muller, Marsaglia-Bray form

Repeat: take u1, u2; set u1 = 2u1 − 1, u2 = 2u2 − 1, X = u1² + u2²; while X > 1.

Then Y = sqrt(−2 ln(X) / X), and the method returns Z1 = u1·Y and Z2 = u2·Y, in that order.
