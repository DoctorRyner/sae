module Main

import Sae.ArgsParser
import Sae.Command
import Sae.Config
import Js.System

{- Project components

* Command
* Args parser that gives us a command
* ipkg generator

-}

evalConfig : Either ConfigError Config -> IO ()
evalConfig (Left configError) = putStrLn $ configErrorToString configError
evalConfig (Right config) = print config

main : IO ()
main = do
    let command = argsToCommand !getArgs
    -- runCommand command
    evalConfig !readConfig
