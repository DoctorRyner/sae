module Sae.Command

import Data.String.Extra
import Data.Maybe
import Js.Console
import Js.Glob
import Js.System
import Sae.Config
import Sae.Info
import Sae.Ipkg
import Sae.Types
import System.Directory
import System.File

availableCommands : List Command
availableCommands =
    [ Help
    , GenerateIpkg
    , FetchDeps
    ]

commandToString : Command -> String
commandToString = \case
    Help => "help: Show usage info"
    GenerateIpkg => "generate-ipkg: Generates ipkg file"
    FetchDeps => "fetch: Fetch dependencies"

usageInfo : String
usageInfo =
    join "\n"
        $ [ "sae — Idris 2 Build Tool"
          , ""
          , "Version: " ++ version
          , ""
          , "Usage: sae [command] [arg*]"
          , ""
          , "Available commands:"
          ]
        ++ map (("  " ++) . commandToString) availableCommands

generateIpkg : Config -> IO ()
generateIpkg cfg = do
    dir <- fromMaybe "./" <$> currentDir
    ipkgFiles <- getFileNames "*.ipkg"

    let ipkgPath = dir ++ "/" ++ cfg.package ++ ".ipkg"
        ipkg = configToIpkg cfg

    case !(writeFile ipkgPath ipkg) of
        Left err => print err
        Right _ =>
            when (not $ cfg.package ++ ".ipkg" `elem` ipkgFiles) $
                putStrLn $ "Generated: " ++ ipkgPath

fetchSource : Source -> IO ()
fetchSource src = do
    let folderName = src.name ++ "-" ++ src.version
        cloneCmd = "git clone " ++ src.url ++ " " ++ folderName
        changeVersionCmd = "git -c advice.detachedHead=false checkout " ++ src.version

    when (!(system cloneCmd) == 0) $ do
        changeDir folderName
        system changeVersionCmd
        changeDir ".."
        pure ()

fetchDeps : Config -> IO ()
fetchDeps cfg = do
    saeDir <- (++ "/.sae/") <$> getHomeDir
    createDir saeDir
    changeDir saeDir
    traverse_ fetchSource cfg.sources

evalCommand : Config -> Command -> IO ()
evalCommand cfg GenerateIpkg = generateIpkg cfg
evalCommand cfg FetchDeps = fetchDeps cfg
evalCommand _ _ = pure ()

evalConfig : Command -> Either ConfigError Config -> IO ()
evalConfig _ (Left configError) = putStrLn $ configErrorToString configError
evalConfig cmd (Right cfg) = evalCommand cfg cmd

export
runCommand : Command -> IO ()
runCommand Help = log usageInfo
runCommand cmd = evalConfig cmd !readConfig