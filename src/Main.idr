module Main

import Data.Maybe
import Data.String.Parser
import Data.Json
import System.Directory
import System.File
import Config

generateIpkg : String -> Config -> IO ()
generateIpkg baseDir cfg = do
  let
    ipkg     = configToIpkg $ record {modules = !(modulesFromSourcedir cfg.sourcedir)} cfg
    ipkgPath = baseDir ++ "/" ++ cfg.package ++ ".ipkg"
  case !(writeFile ipkgPath ipkg) of
    Left err => print err
    Right _  => putStrLn $ "Generated: " ++ ipkgPath

loadConfig : String -> Either FileError String -> IO ()
loadConfig _ (Left  err) = putStrLn $ show err ++ ": Eq.yml"
loadConfig baseDir (Right fileContent) =
  case decode fileContent of
    Left err => print err
    Right x => generateIpkg baseDir $ jsonToConfig x

main : IO ()
main = do
  baseDir <- fromMaybe "/" <$> currentDir
  loadConfig baseDir !(readFile "Eq.json")
