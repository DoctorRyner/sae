module Sae.Command

import public Sae.Config

import Data.Strings
import Sae.Types
import Sae.Utils
import System
import System.Directory
import System.File

mkEqFile : String -> String
mkEqFile package = unlines
  [ "{"
  , "  " ++ qts "package" ++ ": " ++ qts package ++ ","
  , "  " ++ qts "version" ++ ": " ++ qts "0.0.0" ++ ","
  , "  " ++ qts "depends" ++ ": " ++ "[]"
  , "}"
  ]

generateIpkg : String -> Config -> IO ()
generateIpkg baseDir cfg = do
  let
    ipkg     = configToIpkg $ record {modules = !(modulesFromSourcedir cfg.sourcedir)} cfg
    ipkgPath = baseDir ++ "/" ++ cfg.package ++ ".ipkg"
  case !(writeFile ipkgPath ipkg) of
    Left err => print err
    Right _  => putStrLn $ "Generated: " ++ ipkgPath

helpMessage : String
helpMessage = "There is no help message yet"

basicMainFile : String
basicMainFile = unlines
  ["module Main"
  , ""
  , "main : IO ()"
  , "main = putStrLn " ++ qts "Now I gonna solve all of the equations!"
  ]

export
runCmdIO : Command -> IO ()
runCmdIO Help = putStrLn helpMessage
runCmdIO (New package) = do
  createDir package
  changeDir package
  createDir "src"
  writeFile "Eq.json" $ mkEqFile package
  writeFile "src/Main.idr" basicMainFile
  pure ()
runCmdIO _ = pure ()

export
runCmd : Command -> AppIO ()
runCmd Build = do
  state <- get ()
  primIO $ do
    generateIpkg state.baseDir state.cfg
    changeDir state.baseDir
    system $ "idris2 --build " ++ state.cfg.package ++ ".ipkg"
    pure ()
runCmd Install = do
  state <- get ()
  runCmd Build
  primIO $ do
    system $ "idris2 --install " ++ state.cfg.package ++ ".ipkg"
    pure ()
runCmd Release = do
  state <- get ()
  runCmd Build
  primIO $ do
    releaseCode <- system $ concatMap (++ " ")
      [ "idris2"
      , state.cfg.sourcedir ++ "/Main.idr"
      , concatMap ("-p " ++) state.cfg.depends
      , "-o " ++ state.cfg.package
      ]
    putStrLn $
      if releaseCode == 0
      then "Compiled: " ++ state.baseDir ++ "/build/exec/" ++ state.cfg.package
      else "ERROR(" ++ show releaseCode ++ "): Couldn't built " ++ state.cfg.package
runCmd Run = do
  runCmd Build
  state <- get ()
  primIO $ do
    system $ "./build/exec/" ++ state.cfg.package
    pure ()
runCmd _ = pure ()

export
parseArgs : List String -> Command
parseArgs ("new"::x::_) = New x
parseArgs ("build"::_) = Build
parseArgs ("install"::_) = Install
parseArgs ("release"::_) = Release
parseArgs ("run"::_) = Run
parseArgs _ = Help
