module Sae.App

import Control.App
import Control.App.Console
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

decodeConfig : String -> Either FileError String -> Either String Config
decodeConfig _ (Left  err) = Left $ show err ++ ": Eq.json"
decodeConfig baseDir (Right fileContent) =
  case decode fileContent of
    Left err => Left $ show err
    Right x => Right $ jsonToConfig x

loadConfigAndRunCmd : Command -> IO ()
loadConfigAndRunCmd cmd = do
  baseDir <- fromMaybe "/" <$> currentDir
  case decodeConfig baseDir !(readFile "Eq.json") of
    Left err => putStrLn err
    Right cfg => runCmd baseDir cfg cmd

export
runSae : IO ()
runSae = do
  args <- getArgs
  let cmd = parseArgs $ drop 1 args
  case cmd of
    Help => runCmdSimple Help
    New x => runCmdSimple $ New x
    _ => loadConfigAndRunCmd cmd
