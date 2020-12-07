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

exec : String -> Config -> Command -> IO ()
exec _ _ Help = putStrLn "There is no help, suffer"
exec baseDir cfg Release = do
  exec baseDir cfg Build
  releaseCode <- system $ concatMap (++ " ")
    [ "idris2"
    , cfg.sourcedir ++ "/Main.idr"
    , concatMap ("-p " ++) cfg.depends
    , "-o " ++ cfg.package
    ]
  putStrLn $
    if releaseCode == 0
    then "Compiled: " ++ baseDir ++ "/build/exec/" ++ cfg.package
    else "ERROR(" ++ show releaseCode ++ "): Couldn't built " ++ cfg.package
exec baseDir cfg Build = do
  generateIpkg baseDir cfg
  changeDir baseDir
  system $ "idris2 --build " ++ cfg.package ++ ".ipkg"
  pure ()
exec _ _ (New package) = do
  createDir package
  changeDir package
  createDir "src"
  writeFile "Eq.json" $ mkEqFile package
  writeFile
    "src/Main.idr" $
    unlines
      ["module Main"
      , ""
      , "main : IO ()"
      , "main = putStrLn " ++ qts "Now I gonna solve all of the equations!"
      ]
  pure ()

export
execArgs : String -> Config -> List String -> IO ()
execArgs baseDir cfg ("new"::x::xs) = exec baseDir cfg $ New x
execArgs baseDir cfg ("help"::_) = exec baseDir cfg Help
execArgs baseDir cfg ("build"::_) = exec baseDir cfg Build
execArgs baseDir cfg ("release"::_) = exec baseDir cfg Release
execArgs _ _ _ = putStrLn "Type: 'sae help' for help"
