{-# OPTIONS_GHC -Wall #-}
module Main where

import Text.Read (readMaybe)
import System.IO   (hFlush, stdout)
import Data.Time.Clock.POSIX (getPOSIXTime)

-- | Simple PRNG (LCG) seeded by microsecond clock; stays in-base (no extra pkgs)
randInRange :: Int -> Int -> IO Int
randInRange lo hi = do
  t <- getPOSIXTime
  let seed :: Integer
      seed = floor (t * 1000000)  -- microseconds
      -- classic LCG params (glibc-ish)
      a = 1103515245 :: Integer
      c = 12345       :: Integer
      m = 2^(31 :: Int) :: Integer
      r = (a * seed + c) `mod` m
      span' = toInteger (hi - lo + 1)
      val = fromInteger (r `mod` span') + lo
  pure val

-- | Safe prompt that keeps asking until the parser returns Just a
promptParse :: String -> (String -> Maybe a) -> IO a
promptParse msg parser = do
  putStr msg
  putStr " "
  hFlush stdout
  line <- getLine
  case parser line of
    Just a  -> pure a
    Nothing -> putStrLn "✗ Invalid input, try again.\n" >> promptParse msg parser

-- | Parse bounded natural numbers
readBoundedNat :: Int -> Int -> String -> Maybe Int
readBoundedNat lo hi s = do
  n <- readMaybe s :: Maybe Int
  if n >= lo && n <= hi then Just n else Nothing

-- | One full round of the game; returns True if player wants to play again
playRound :: IO Bool
playRound = do
  putStrLn "=============================="
  putStrLn "     🎯 Guess The Number!     "
  putStrLn "=============================="
  putStrLn "Choose a difficulty:"
  putStrLn "  1) Easy    (1–50,   8 tries)"
  putStrLn "  2) Normal  (1–100, 10 tries)"
  putStrLn "  3) Hard    (1–1000,12 tries)"
  putStrLn ""

  choice <- promptParse "Enter 1, 2, or 3:" (readBoundedNat 1 3)

  let (lo, hi, tries) = case choice of
        1 -> (1, 50,   8)
        2 -> (1, 100, 10)
        _ -> (1, 1000,12)

  secret <- randInRange lo hi
  putStrLn $ "\nI've picked a number between " ++ show lo ++ " and " ++ show hi ++ "."
  putStrLn $ "You have " ++ show tries ++ " tries. Good luck!\n"

  result <- loop secret lo hi tries 1
  case result of
    Just attempts -> putStrLn $ "✅ Correct! You got it in " ++ show attempts ++ " attempt(s)."
    Nothing       -> putStrLn $ "❌ Out of tries! The number was " ++ show secret ++ "."

  putStrLn ""
  again <- promptParse "Play again? (y/n):" yesNo
  pure again
  where
    yesNo :: String -> Maybe Bool
    yesNo s = case toLowerStr (trim s) of
      "y"   -> Just True
      "yes" -> Just True
      "n"   -> Just False
      "no"  -> Just False
      _     -> Nothing

    toLowerStr :: String -> String
    toLowerStr = map toLowerChar

    toLowerChar :: Char -> Char
    toLowerChar c
      | 'A' <= c && c <= 'Z' = toEnum (fromEnum c + 32)
      | otherwise            = c

    trim :: String -> String
    trim = f . f
      where f = reverse . dropWhile (== ' ')

-- | The guessing loop
loop :: Int -> Int -> Int -> Int -> Int -> IO (Maybe Int)
loop secret lo hi remaining attemptNum
  | remaining <= 0 = pure Nothing
  | otherwise = do
      putStrLn $ "Attempts left: " ++ show remaining
      guess <- promptParse ("Enter your guess (" ++ show lo ++ "–" ++ show hi ++ "):")
                           (readBoundedNat lo hi)
      case compare guess secret of
        EQ -> pure (Just attemptNum)
        LT -> do
          putStrLn "Too LOW 🔽"
          giveHint guess secret lo hi
          putStrLn ""
          loop secret lo hi (remaining - 1) (attemptNum + 1)
        GT -> do
          putStrLn "Too HIGH 🔼"
          giveHint guess secret lo hi
          putStrLn ""
          loop secret lo hi (remaining - 1) (attemptNum + 1)

-- | A tiny adaptive hint
giveHint :: Int -> Int -> Int -> Int -> IO ()
giveHint guess secret lo hi = do
  let diff  = abs (secret - guess)
      span' = hi - lo
      proximity
        | diff == 0                  = "spot on!"
        | diff <= span' `div` 50 + 1 = "🔥 very hot"
        | diff <= span' `div` 20 + 1 = "🌶️ hot"
        | diff <= span' `div` 10 + 1 = "🙂 warm"
        | otherwise                  = "🥶 cold"
  putStrLn $ "Hint: you're " ++ proximity ++ "."

main :: IO ()
main = do
  putStrLn "Welcome!"
  let game = do
        again <- playRound
        if again then game else putStrLn "Thanks for playing! 👋"
  game
