module Main

import Sae.ArgsParser
import Sae.Command
import Sae.Config
import System

{- Project components

* Command
* Args parser that gives us a command
* ipkg generator

-}

evalConfig : Maybe Config -> IO ()
evalConfig Nothing = pure ()
evalConfig (Just cfg) = pure ()

main : IO ()
main = do
    let command = argsToCommand !getArgs
    -- runCommand command
    evalConfig !(readConfig "")
