# 🎯 Guess The Number (Haskell)

[![CI](https://github.com/miSSkSambo/guess-number/actions/workflows/ci.yml/badge.svg)](https://github.com/miSSkSambo/guess-number/actions/workflows/ci.yml)


[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Haskell](https://img.shields.io/badge/Lang-Haskell-purple)
![Build](https://img.shields.io/badge/Build-GHC%20%7C%20Cabal%20%7C%20Stack-blue)

A tiny, friendly console game written in **pure Haskell**. Pick a difficulty, then guess the secret number within a limited number of attempts. Get adaptive hints (🔥 *very hot* → 🥶 *cold*) as you go.

This version avoids `System.Random` so it runs cleanly on most online compilers. It uses a tiny in-file PRNG seeded from the system clock (`Data.Time.Clock.POSIX`).

---

## ✨ Features
- **3 difficulties**: Easy (1–50, 8 tries) • Normal (1–100, 10 tries) • Hard (1–1000, 12 tries)
- **Input validation**: never crashes on bad input
- **Adaptive hints**: very hot / hot / warm / cold
- **Replay loop**: play as many rounds as you want

---

## 🚀 Quick Start

### A) Compile with GHC
```bash
ghc -O2 --make src/Main.hs -o guess
./guess
```

### B) Cabal
```bash
cabal update
cabal build
cabal run
```

### C) Stack
```bash
stack build
stack run
```

### D) Online Compilers
Paste `src/Main.hs` into an online GHCi (Replit, JDoodle, etc.) and run.  
> If your REPL forbids `getPOSIXTime`, use the **seeded** mode below.

---

## 🧪 Example Session

```
Welcome!
==============================
     🎯 Guess The Number!
==============================
Choose a difficulty:
  1) Easy    (1–50,   8 tries)
  2) Normal  (1–100, 10 tries)
  3) Hard    (1–1000,12 tries)

Enter 1, 2, or 3: 2

I've picked a number between 1 and 100.
You have 10 tries. Good luck!

Attempts left: 10
Enter your guess (1–100): 50
Too LOW 🔽
Hint: you're 🙂 warm.

Attempts left: 9
Enter your guess (1–100): 75
Too HIGH 🔼
Hint: you're 🌶️ hot.

Attempts left: 8
Enter your guess (1–100): 68
✅ Correct! You got it in 3 attempt(s).

Play again? (y/n): n
Thanks for playing! 👋
```

---

## 🧠 How It Works
- The game seeds a tiny **Linear Congruential Generator (LCG)** with microseconds from the system clock, then maps the result into your chosen range.
- **No extra packages** are required; we only depend on `base` and `time` (for `getPOSIXTime`).

### Deterministic (Seeded) Mode
If your environment blocks `getPOSIXTime`, you can switch to a deterministic version. Replace `randInRange` in `src/Main.hs` with:

```haskell
-- Ask the player for a seed; deterministic across runs
randInRange :: Int -> Int -> IO Int
randInRange lo hi = do
  putStrLn "Enter a seed (integer):"
  s <- readLn :: IO Int
  let a = 1103515245 :: Integer
      c = 12345       :: Integer
      m = 2^(31 :: Int) :: Integer
      r = (a * fromIntegral s + c) `mod` m
      span' = toInteger (hi - lo + 1)
  pure (fromInteger (r `mod` span') + lo)
```

---

## 📦 Project Structure
```
.
├── cabal.project
├── guess-number.cabal
├── LICENSE
├── README.md
├── src
│   └── Main.hs
├── stack.yaml
└── .gitignore
```

---

## 🧩 Troubleshooting
- **`Could not find module 'Data.Time.Clock.POSIX'`**  
  Ensure `time` is available. With Cabal/Stack it’s declared under `build-depends`.

- **Online REPL still fails**  
  Use the deterministic **seeded** version above.

---

## 🤝 Contributing
PRs welcome! Feel free to open issues for features like a scoreboard, attempt history, or a “hints off” hard mode.

---

## 📄 License
MIT © 2025 Katlego Sambo
