module Markov.Walker (randomWalk) where

import Markov.Chain

import System.Random (randomRIO)

-- take a random walk of a maximum given number of steps
-- through a given Markov process
-- TODO: refactor ugly code
randomWalk :: Ord a => Chain a -> a -> Int -> IO [a]
randomWalk c s n = if n <= 0
    then return []
    else do
        mns <- next c s
        case mns of
            Nothing -> return []
            Just ns -> do
                rw' <- randomWalk c ns (n - 1)
                return $ s : rw'

-- given a state, randomly select a next state from a chain
-- based on the probability distribution of the accessible
-- states
next :: Ord a => Chain a -> a -> IO (Maybe a)
next c s = do
    let accs = accessibleStates c s
    rn <- randomRIO (0, sumProb accs)
    return $ next' rn 0 $ sortByProb accs
    where
    next' _ _ [] = Nothing
    next' _ _ (sp : []) = Just $ fst sp
    next' rn acc ((s, p) : sps) = -- sample
        if rn <= acc + p
            then Just s
            else next' rn (acc + p) sps
