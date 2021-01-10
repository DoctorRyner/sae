module Main

import Data.List
import Sae.ArgsParser
import Sae.Command
import Sae.Config
import System

main : IO ()
main = do
    args <- drop 1 <$> getArgs
    runCommand $ argsToCommand args
