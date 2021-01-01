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

evalConfig : Either ConfigError Config -> IO ()
evalConfig (Left configError) = putStrLn $ "Error => " ++ configErrorToString configError
evalConfig (Right config) = pure ()

main : IO ()
main = do
    let command = argsToCommand !getArgs
    -- runCommand command
    evalConfig !readConfig
