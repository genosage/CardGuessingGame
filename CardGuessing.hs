module CardGuessing (feedback, initialGuess, nextGuess, GameState) where


import Card
import Data.List


-- | GameState type can store the list of all the remaining possible answers.
type GameState = [[Card]]

-- | feedback function takes a target and a guess (in that order), each
--   represented as a list of Cards, and returns the five feedback numbers,
--   (correct cards, lower ranks, correct ranks, higher ranks, correct suits),
--   as a tuple. Four helper functions are used to calculate the feedback.
feedback :: [Card] -> [Card] -> (Int,Int,Int,Int,Int)
feedback answer guess = (i1,i2,i3,i4,i5)
    where i1 = correctCard answer guess
          i3 = correctRank answer guess
          i5 = correctSuit answer guess
          (i2,i4) = lowerAndHigher answer guess 


-- | initialGuess function takes the number of cards in the answer as input
--   and returns a pair of an initial guess, which is a list of the specified
--   number of cards, and a game state. The GameState of the initial guess
--   should be the combination of the list of all the cards without
--   replication, for example, when the input number is 2, the GameState
--   should be [[2C,3C]],[2C,4C]...[QS,AS],[KS,AS]].
initialGuess :: Int -> ([Card],GameState)
initialGuess i = (initialGuessHelper i, combination i lst)
    where lst = ([minBound..maxBound] :: [Card])


-- | nextGuess takes as input a pair of the previous guess and game state,
--   and the feedback to this guess as a quintuple of counts of correct cards,
--   low ranks, correct ranks, high ranks, and correct suits, and returns a
--   pair of the next guess and new game state. The remaining possible answers
--   are those which will give the same feedback as the real answer.
nextGuess :: ([Card],GameState) -> (Int,Int,Int,Int,Int) -> ([Card],GameState)
nextGuess (guess, gameState) fb
    | length guess == 2 = (newGuess, newGameState)
    | otherwise = (newGameState!!0, newGameState)
    where newGameState = [x | x <- gameState, feedback x guess == fb]
          newGuess = bestGuess newGameState


-- **************************************************************************
-- **************************** Helper Functions ****************************
-- **************************************************************************


-- | correctCard is a helper function which takes a target and a guess and
--   can return the number of the correct cards.
correctCard :: [Card] -> [Card] -> Int
correctCard [] _ = 0
correctCard (x:xs) lst
    | elem x lst = i+1
    | otherwise = i
    where i = correctCard xs lst


-- | correctSuit is a helper function which takes a target and a guess and
--   can return the number of the correct suits.
correctSuit :: [Card] -> [Card] -> Int
correctSuit [] _ = 0
correctSuit ((Card s r):xs) lst
    | elem targetSuit suitList = i2+1
    | otherwise = i1
    where suitList = map (`div` 13) (map fromEnum lst)
          targetSuit = fromEnum s
          index = newElemIndex targetSuit suitList
          i1 = correctSuit xs lst
          i2 = correctSuit xs (removeElem index lst)


-- | correctRank is a helper function which takes a target and a guess and
--   can return the number of the correct ranks.
correctRank :: [Card] -> [Card] -> Int
correctRank [] _ = 0
correctRank ((Card s r):xs) lst
    | elem targetRank rankList = i2+1
    | otherwise = i1
    where rankList = map (`mod` 13) (map fromEnum lst)
          targetRank = fromEnum r
          index = newElemIndex targetRank rankList
          i1 = correctRank xs lst
          i2 = correctRank xs (removeElem index lst)


-- | lowerAndHigher is a helper function which takes a target and a guess and
--   can return the numbers of the lower ranks and higher ranks.
lowerAndHigher :: [Card] -> [Card] -> (Int,Int)
lowerAndHigher [] _ = (0,0)
lowerAndHigher ((Card s r):xs) lst
    | targetRank < (head sortedRankLst) = (i1+1,i2)
    | targetRank > (last sortedRankLst) = (i1,i2+1)
    | otherwise = (i1,i2)
    where sortedRankLst = sort (map (`mod` 13) (map fromEnum lst))
          targetRank = fromEnum r
          (i1,i2) = lowerAndHigher xs lst


-- | removeElem takes a number(index) and a list as input and remove the
--   element of that index in the list.
removeElem :: Int -> [a] -> [a]
removeElem _ [] = []
removeElem i (x:xs)
    | i < 0 = error "Index is less than 0!"
    | i == 0 = xs
    | otherwise = x:(removeElem (i-1) xs)


-- | newElemIndex takes an element and a list and will return the index of
--   that element in the list(-1 if the element does not exist).
newElemIndex :: Eq a => a -> [a] -> Int
newElemIndex _ [] = -1
newElemIndex x lst = eliminate (elemIndex x lst)


-- | eliminate can transfer Maybe Int to Int.
eliminate :: Maybe Int -> Int
eliminate Nothing = -1
eliminate (Just i) = i


-- | initialGuessHelper can return the initial guess depending on the
--   input number.
initialGuessHelper :: Int -> [Card]
initialGuessHelper i
    | i == 2 = [Card Club R6, Card Heart R10]
    | i == 3 = [Card Club R4, Card Heart R8, Card Spade Queen]
    | i == 4 = [Card Club R3, Card Diamond R6, Card Heart R9, Card Spade Queen]


-- | combination takes a number(size) and a list and will return all the
--   combinations of the list of that size. For example, combination 2 [1,2,3]
--   will return [[1,2],[1,3],[2,3]].
combination :: Int -> [a] -> [[a]]
combination 0 _ = [[]]
combination _ [] = []
combination n xs@(y:ys)
    | n < 0     = []
    | otherwise = case drop (n-1) xs of
                  [ ] -> []
                  [_] -> [xs]
                  _   -> [y:c | c <- combination (n-1) ys] ++ combination n ys


-- | groupGameState takes a candidate guess and a list of possible answers,
--   and will group all the answers related to the feedback.
groupGameState :: [Card] -> GameState -> [((Int,Int,Int,Int,Int), Int)]
groupGameState _ [] = []
groupGameState lst (x:xs)
    | elem targetFb fbList = (targetFb,i+1):(removeElem index result)
    | otherwise = (targetFb,1):result
    where result = groupGameState lst xs
          fbList = map fst result
          targetFb = feedback x lst
          index = newElemIndex targetFb fbList
          (_,i) = result!!index


-- | expectedNum takes a candidate guess and a  list of possible answers,
--   and will return the weight of that guess.
expectedNum :: [Card] -> GameState -> Int
expectedNum guess gameState = (sum (map square sizes)) `div` (sum sizes)
    where groups = groupGameState guess gameState
          sizes = map snd groups


-- | the square of a number.
square :: Int -> Int
square x = x * x


-- | allExpectedNum takes a game state and itself and will return the weight
--   of every possible answer of the game state.
allExpectedNum :: GameState -> GameState -> [Int]
allExpectedNum [] _ = []
allExpectedNum (x:xs) gameState = (expectedNum x restGameState):result
    where result = allExpectedNum xs gameState
          index = newElemIndex x gameState
          restGameState = removeElem index gameState


-- | bestGuess takes a game state and will return a guess which has the
--   minimun weight.
bestGuess :: GameState -> [Card]
bestGuess [x] = x
bestGuess gameState = gameState!!index
    where numbers = allExpectedNum gameState gameState
          index = newElemIndex (minimum numbers) numbers