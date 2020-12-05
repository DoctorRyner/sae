module Config

import Data.Either
import Data.List
import Data.Yaml
import Data.Maybe
import Data.String.Extra
import Data.String.Parser
import Data.Strings
import System.Directory
import Parser

public export
record Config where
  constructor MkConfig
  package,
  version,
  target,
  sourcedir : String
  modules   : List String

export
yamlToConfig : List Value -> Config
yamlToConfig xs =
  let
    list      = map (\(MkObject key val) => (key, val)) xs
    package   = fromMaybe "default" $ lookup "package"   list
    version   = fromMaybe "0.0.0"   $ lookup "version"   list
    target    = fromMaybe "chez"    $ lookup "target"    list
    sourcedir = fromMaybe "src"     $ lookup "sourcedir" list
  in MkConfig package version target sourcedir []

export
configToIpkg : Config -> String
configToIpkg cfg = concatMap (++ "\n")
  [ "package " ++ cfg.package ++ "-" ++ (pack $ map (\x => if x == '.' then '_' else x) $ unpack cfg.version) ++ "\n"
  , "sourcedir = \"" ++ cfg.sourcedir ++ "\""
  , if length cfg.modules == 0
    then ""
    else "modules = " ++ join "\n        , " cfg.modules
  ]

getDirs : String -> IO (List String)
getDirs path = case !(openDir path) of
  Left  _   => pure []
  Right dir => do
    changeDir path
    files <- filter (\x => x /= "." && x /= "..") <$> getDirs' dir
    pure files
 where
  getDirs' : Directory -> IO (List String)
  getDirs' dir = case !(dirEntry dir) of
    Left  _       => pure []
    Right dirName => ([dirName] ++) <$> getDirs' dir

export
modulesFromSourcedir : String -> IO (List String)
modulesFromSourcedir path = do
  if not !(changeDir path)
    then pure []
    else do
      mbDir <-currentDir
      let dir = fromMaybe "/" mbDir
      files <- getDirs dir
      let idrisFiles = filter (isSuffixOf ".idr") files
      let restFiles = filter (not . isSuffixOf ".idr") files
      idrisFilesContents <- traverse readFile idrisFiles
      let modules = map fst $ rights $ map (parse moduleDecl) $ rights idrisFilesContents
      if files == []
        then pure []
        else do
          modulesBunch <- traverse modulesFromSourcedir restFiles
          pure $ modules ++ concat modulesBunch
