module Main

import Data.List
import Sae.App
import System

main : IO ()
main = runSae $ drop 1 !getArgs
