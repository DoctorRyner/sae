module Main

import Data.Maybe
import Data.String.Parser
import Data.Json
import System.Directory
import System.File
import Parser
import Config

-- mkConfigMsg : Either String (List Value, Int) -> String
-- mkConfigMsg = either show (configToIpkg . yamlToConfig . fst)

-- generateIpkg2 : String -> Config -> IO ()
-- generateIpkg2 baseDir cfg = do
--   let
--     ipkg     = configToIpkg $ record {modules = !(modulesFromSourcedir cfg.sourcedir)} cfg
--     ipkgPath = baseDir ++ "/" ++ cfg.package ++ ".ipkg"
--   case !(writeFile ipkgPath ipkg) of
--     Left err => print err
--     Right _  => putStrLn $ "Generated: " ++ ipkgPath

-- loadConfig : String -> Either FileError String -> IO ()
-- loadConfig _ (Left  err        ) = putStrLn $ show err ++ ": Eq.yml"
-- loadConfig baseDir (Right fileContent) = either print (generateIpkg2 baseDir . yamlToConfig . fst) $ parse yamlObject fileContent

testJsonObj : Value
testJsonObj =
  MkObject
  [ ("package", MkString "sae")
  , ("version", MkString "0.0.1")
  , ( "depends"
    , MkArray
        [ MkString "contrib"
        , MkObject [("x", MkNumber 0), ("y", MkNumber 0)]
        , MkNumber 6 -- "idris2"
        ]
    )
  ]

main : IO ()
main =
  case !(readFile "Eq.json") of
    Left err => print err
    Right x => either putStrLn print $ decode x


  -- either print (print . parse ymlVal) !(readFile "Eq.yml")
  -- baseDir <- fromMaybe "/" <$> currentDir
  -- loadConfig baseDir !(readFile "Eq.yml")
