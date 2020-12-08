module Sae.Config

import Data.Either
import Data.List
import Data.Json
import Data.Maybe
import Data.String.Extra
import Data.String.Parser
import Data.Strings
import Sae.Parser
import Sae.Types
import System
import System.Directory

fromMbJsonString : String -> Maybe Value -> String
fromMbJsonString _ (Just (MkString x)) = x
fromMbJsonString fallback _ = fallback

export
jsonToConfig : Value -> Config
jsonToConfig (MkObject xs) =
  let
    package = fromMbJsonString "default" $ lookup "package" xs
    version = fromMbJsonString "0.0.0" $ lookup "version" xs
    target = fromMbJsonString "chez" $ lookup "target" xs
    sourcedir = fromMbJsonString "src" $ lookup "sourcedir" xs
    depends =
      case lookup "depends" xs of
        Just (MkArray xs) =>
          rights $
            map
              (\case
                MkString x => Right $ pack $ map (\c => if c == '.' then '_' else c) $ unpack x
                _ => Left ()
              )
              xs
        _ => []
    sources =
      case lookup "sources" xs of
        Just (MkArray xs) =>
          rights $
            map
              (\case
                MkString x => Right x
                _ => Left ()
              )
              xs
        _ => []
  in MkConfig package version target sourcedir depends sources []
jsonToConfig _ = MkConfig "default" "0.0.0" "chez" "src" [] [] []

export
configToIpkg : Config -> String
configToIpkg cfg = concatMap (++ "\n")
  [ "package " ++ cfg.package ++ "-" ++ (pack $ map (\x => if x == '.' then '_' else x) $ unpack cfg.version) ++ "\n"
  , "sourcedir = \"" ++ cfg.sourcedir ++ "\"\n"
  , if length cfg.depends == 0
    then ""
    else "depends = " ++ join "\n        , " cfg.depends ++ "\n"
  , if length cfg.modules == 0
    then ""
    else "modules = " ++ join "\n        , " cfg.modules
  ]

export
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
      mbDir <- currentDir
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

export
loadDeps : String -> List String -> IO ()
loadDeps baseDir urls = do
  changeDir baseDir
  createDir "deps"
  changeDir $ baseDir ++ "/deps"
  traverse (system . ("git clone " ++)) urls
  pure ()

export
installDeps : String -> List String -> IO ()
installDeps baseDir urls = do
  loadDeps baseDir urls
  changeDir baseDir
  dirs <- getDirs "deps"
  changeDir "deps"
  traverse_
    (\dir => do
      changeDir $ baseDir ++ "/deps/" ++ dir
      system "sae build-deps"
      system "sae install"
    )
    dirs
