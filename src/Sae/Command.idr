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
  dirs <- getDirs baseDir

  let
    ipkg     = configToIpkg $ record {modules = !(modulesFromSourcedir cfg.sourcedir)} cfg
    ipkgPath = baseDir ++ "/" ++ cfg.package ++ ".ipkg"

  case !(writeFile ipkgPath ipkg) of
    Left err => print err
    Right _  =>
      when (not (cfg.package ++ ".ipkg" `elem` dirs)) $
        putStrLn $ "Generated: " ++ ipkgPath

helpMessage : String
helpMessage = unlines
  [ "Usage:"
  , ""
  , "# Create new project"
  , "sae new project-name"
  , ""
  , "# Fetch dependencies"
  , "sae fetch"
  , ""
  , "# Build (and fetch) dependencies"
  , "sae build-deps"
  , ""
  , "# Build project"
  , "sae build"
  , ""
  , "# Install (and build) project as a library"
  , "sae install"
  , ""
  , "# Build executable"
  , "sae release"
  , ""
  , "# Run (and build) executable"
  , "sae run"
  ]

basicMainFile : String
basicMainFile = unlines
  ["module Main"
  , ""
  , "main : IO ()"
  , "main = putStrLn " ++ qts "Now I gonna solve all of the equations!"
  ]

export
runCmdSimple : Command -> IO ()
runCmdSimple Help = putStrLn helpMessage
runCmdSimple (New package) = do
  createDir package
  changeDir package
  createDir "src"
  writeFile "Eq.json" $ mkEqFile package
  writeFile "src/Main.idr" basicMainFile
  writeFile ".gitignore" $ unlines ["deps/", "build/", "DS_Store", "*.ipkg"]
  pure ()
runCmdSimple _ = pure ()

export
runCmd : String -> Config -> Command -> IO ()
runCmd baseDir cfg Build = do
  generateIpkg baseDir cfg
  changeDir baseDir
  system $ "idris2 --build " ++ cfg.package ++ ".ipkg"
  pure ()
runCmd baseDir cfg Install = do
  runCmd baseDir cfg Build
  system $ "idris2 --install " ++ cfg.package ++ ".ipkg"
  pure ()
runCmd baseDir cfg Release = do
  runCmd baseDir cfg Build
  let
    executableName = if cfg.target == "javascript" then "index.js" else cfg.package
    releaseCmd = concatMap (++ " ")
      [ "idris2"
      , cfg.sourcedir ++ "/Main.idr"
      , "--codegen " ++ cfg.target
      , concatMap (" -p " ++) cfg.depends
      , "-o " ++ executableName
      ]
  releaseCode <- system releaseCmd
  putStrLn $
    if releaseCode == -1
    then "ERROR(" ++ show releaseCode ++ "): Couldn't built " ++ cfg.package
    else "Compiled: " ++ baseDir ++ "/build/exec/" ++ executableName
runCmd baseDir cfg Run = do
  runCmd baseDir cfg Build
  system $ "./build/exec/" ++ cfg.package
  pure ()
runCmd baseDir cfg FetchDeps = loadDeps baseDir cfg.sources
runCmd baseDir cfg BuildDeps = installDeps baseDir cfg.sources
runCmd _ _ _ = pure ()

export
parseArgs : List String -> Command
parseArgs ("new"::x::_) = New x
parseArgs ("build"::_) = Build
parseArgs ("install"::_) = Install
parseArgs ("release"::_) = Release
parseArgs ("run"::_) = Run
parseArgs ("fetch"::_) = FetchDeps
parseArgs ("build-deps"::_) = BuildDeps
parseArgs _ = Help
