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

loadConfig : String -> Either FileError String -> Either String Config
loadConfig _ (Left  err) = Left $ show err ++ ": Eq.json"
loadConfig baseDir (Right fileContent) =
  case decode fileContent of
    Left err => Left $ show err
    Right x => Right $ jsonToConfig x

app : Command -> AppIO ()
app = runCmd

appReactor : Command -> (Console Init, State () AppState Init) => App Init ()
appReactor cmd = handle (app cmd) pure print

runWithState : AppState -> Command -> IO ()
runWithState state cmd = run $ new state $ appReactor cmd

export
runSae : IO ()
runSae = do
  args <- getArgs
  let cmd = parseArgs $ drop 1 args
  case cmd of
    Help => runCmdIO Help
    New x => runCmdIO $ New x
    _ => do
      baseDir <- fromMaybe "/" <$> currentDir
      case loadConfig baseDir !(readFile "Eq.json") of
        Left err => putStrLn err
        Right cfg => do
          runWithState (MkAppState cfg baseDir) cmd
