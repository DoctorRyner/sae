module Sae.Utils

import System

export
failMsg : String -> IO ()
failMsg msg = do
    putStrLn msg
    exitFailure