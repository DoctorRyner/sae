module Sae.Config

import Control.Monad.ExceptIO
import Sae.Types

readConfigApp : Monad (ExceptIO ConfigError) => ExceptIO ConfigError Config
readConfigApp = do
    putStrLn "Before exception"
    throwErr $ UnknownField "exc1"
    putStrLn "After exception"
    throwErr $ UnknownField "exc2"

-- export
-- readConfig : String -> IO (Either ConfigError Config)
-- readConfig path = runExceptIO readConfigApp
