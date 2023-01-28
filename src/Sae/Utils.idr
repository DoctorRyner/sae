module Sae.Utils

import System
import Data.String.Extra

export
failMsg : String -> IO ()
failMsg msg = do
    putStrLn msg
    exitFailure

export
startsWith : String -> String -> Bool
startsWith prefix' str = prefix' == take (length prefix') str
