module Sae.App

import Control.App
import Data.Json
import Data.Maybe
import Data.List
import Data.String.Parser
import Sae.Config
import Sae.Command
import Sae.Types
import System.Directory
import System.File
import System

loadConfig : String -> Either FileError String -> Either String Config
loadConfig _ (Left  err) = Left $ show err ++ ": Eq.json"
loadConfig baseDir (Right fileContent) =
  case decode fileContent of
    Left err => Left $ show err
    Right x => Right $ jsonToConfig x

export
runSae : IO ()
runSae = do
  args <- getArgs
  baseDir <- fromMaybe "/" <$> currentDir
  case loadConfig baseDir !(readFile "Eq.json") of
    Left err => putStrLn err
    Right cfg => execArgs baseDir cfg $ drop 1 args

runAppIO : AppState -> AppIO () -> App [AppError] ()
runAppIO = new
