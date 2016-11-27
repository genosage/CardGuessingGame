# Card Guessing Game

This is a two-player logical guessing game implemented in Haskell. In this game, two players face each other, each with a complete standard deck of western playing cards (without jokers). One player will be the answerer and the other is the guesser. The answerer begins by selecting some number of cards from his or her deck without showing the guesser. These cards will form the answer for this game. The aim of the game is for the guesser to guess the answer.

----------

## Game Flow
At the beginning, the answerer selects the answer, the guesser then chooses the same number of cards from his or her deck to form the guess and shows them to the answerer. The answerer responds by telling the guesser these five numbers as feedback for the guess:

1. How many of the cards in the answer are also in the guess (correct cards).

2. How many cards in the answer have rank lower than the lowest rank in the guess (lower ranks). Ranks, in order from low to high, are 2–10, Jack, Queen, King, and Ace.

3. How many of the cards in the answer have the same rank as a card in the guess (correct ranks). For this, each card in the guess is only counted once. That is, if the answer has two queens and the guess has one, the correct ranks number would be 1, not 2. Likewise if there is one queen in the answer and two in the guess.

4. How many cards in the answer have rank higher than the highest rank in the guess (higher ranks).

5. How many of the cards in the answer have the same suit as a card in the guess, only counting a card in the guess once (correct suits). For example, if the answer has two clubs and the guess has one club, or vice versa, the correct suits number would be 1, not 2.

The order of the cards in the answer and the guess is immaterial, and that, since they come from a single deck, cards cannot be repeated in either answer or guess.

The guesser then guesses again, and receives feedback for the new guess, repeating the process until the guesser guesses the answer correctly. The object of the game for the guesser is to guess the answer with the fewest possible guesses.

### Examples
A few examples of the feedback for a given answer and guess:

| Answer | Guess | Feedback | Explanation |
| :----: | :---: | :------: | :--------- |
| 3 Club, 4 Heart | 4 Heart, 3 Club | 2,0,2,0,2 | 2 answer cards match guess cards, no answer cards less than a 3, 2 answer cards match guess ranks, no answer cards greater than a 4, 2 answer cards match guess suits. |
| 3 Club, 4 Heart | 3 Club, 3 Heart | 1,0,1,1,2 | 1 exact match (3 Club), no answer cards less than a 3, 1 answer card matches a guess rank, 1 answer card greater than a 3, 2 answer cards match guess suits. |
| 3 Diamond, 3 Heart | 3 Spade, 3 Club | 0,0,2,0,0 | No exact matches, no answer cards less than a 3, 2 an- swer cards match a guess rank, no answer cards greater than a 3, no answer cards match guess suits. |
| 3 Club, 4 Heart | 2 Heart, 3 Heart | 0,0,2,0,0 | No exact matches, no answer cards less than a 2, 1 an- swer card matches a guess rank (the 3), 1 answer card greater than a 3, 1 answer card match a guess suit (Heart). |
| Ace Club, 2 Club | 3 Club, 4 Heart | 0,0,2,0,0 | No exact matches, 1 answer card less than a 3 (the 2; A is high), no answer card matches a guess rank, 1 answer card greater than a 4 (the A), 1 answer card match a guess suit (either Club; you can only count 1 because there’s only 1 Club in the guess). |

## Install and Run

1. [Download](https://www.haskell.org/downloads) the Haskell Working Environment.

2. Run the following commands in terminal: 

```
$ cd /CardGuessingGame
$ ghci
Prelude> :load CardGuessingDriver.hs
*CardGuessingDriver> guessTest "2H 3D AC"
```