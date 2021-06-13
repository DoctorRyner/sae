module Main

import Data.List
import Sae.ArgsParser
import Sae.Command
import Sae.Config
import System

main : IO ()
main = runCommand $ argsToCommand $ drop 2 !getArgs
