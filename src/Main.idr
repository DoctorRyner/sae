module Main

import Data.Maybe
import Data.String.Parser
import Data.Yaml
import System.Directory
import System.File
import Parser
import Config

mkConfigMsg : Either String (List Value, Int) -> String
mkConfigMsg = either show (configToIpkg . yamlToConfig . fst)

generateIpkg2 : String -> Config -> IO ()
generateIpkg2 baseDir cfg = do
  let
    ipkg     = configToIpkg $ record {modules = !(modulesFromSourcedir cfg.sourcedir)} cfg
    ipkgPath = baseDir ++ "/" ++ cfg.package ++ ".ipkg"
  case !(writeFile ipkgPath ipkg) of
    Left err => print err
    Right _  => putStrLn $ "Generated: " ++ ipkgPath

loadConfig : String -> Either FileError String -> IO ()
loadConfig _ (Left  err        ) = putStrLn $ show err ++ ": Eq.yml"
loadConfig baseDir (Right fileContent) = either print (generateIpkg2 baseDir . yamlToConfig . fst) $ parse yamlObject fileContent

main : IO ()
main = do
  baseDir <- fromMaybe "/" <$> currentDir
  loadConfig baseDir !(readFile "Eq.yml")
