module Sae.Command

import Data.String.Extra
import Data.Maybe
import Js.Console
import Js.Glob
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
    ]

commandToString : Command -> String
commandToString = \case
    Help => "help: Show usage info"
    GenerateIpkg => "generate-ipkg: Generates ipkg file"

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
    ipkgFiles <- getFileNames "*"

    let ipkgPath = dir ++ "/" ++ cfg.package ++ ".ipkg"
        ipkg = configToIpkg cfg

    case !(writeFile ipkgPath ipkg) of
        Left err => print err
        Right _ =>
            when (not $ cfg.package ++ ".ipkg" `elem` ipkgFiles) $
                putStrLn $ "Generated: " ++ ipkgPath

evalCommand : Config -> Command -> IO ()
evalCommand cfg GenerateIpkg = generateIpkg cfg
evalCommand _ _ = pure ()

evalConfig : Command -> Either ConfigError Config -> IO ()
evalConfig _ (Left configError) = putStrLn $ configErrorToString configError
evalConfig cmd (Right cfg) = evalCommand cfg cmd

export
runCommand : Command -> IO ()
runCommand Help = log usageInfo
runCommand cmd = evalConfig cmd !readConfig