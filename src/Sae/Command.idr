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
    , BuildDeps
    , Build
    , Install
    ]

commandToString : Command -> String
commandToString = \case
    Help => "help: Show usage info"
    GenerateIpkg => "generate-ipkg: Generates ipkg file"
    FetchDeps => "fetch: Fetch dependencies"
    BuildDeps => "build-deps: Build dependencies"
    Build => "build: Build project"
    Install => "install: Register package in the system"

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
fetchSource src =
    let folderName = src.name ++ "-" ++ src.version
        cloneCmd = "git clone " ++ src.url ++ " " ++ folderName
        changeVersionCmd = "git -c advice.detachedHead=false checkout " ++ src.version
    in
    when (not !(doesFileExist folderName)) $ do
        when (!(systemLegacy cloneCmd) == 0) $ do
            changeDir folderName
            system changeVersionCmd
            changeDir ".."
            pure ()

fetchDeps : Config -> IO ()
fetchDeps cfg = do
    depsDir <- (++ "/.sae/") <$> getHomeDir
    createDir depsDir
    changeDir depsDir
    traverse_ fetchSource cfg.sources

build : Config -> IO ()
build cfg = do
    generateIpkg cfg
    system $ "idris2 --build " ++ cfg.package ++ ".ipkg"
    pure ()

install : Config -> IO ()
install cfg = do
    putStrLn $ "package: " ++ cfg.package ++ "-" ++ cfg.version
    system $ "idris2 --install " ++ cfg.package ++ ".ipkg"
    pure ()

mutual
    buildSource : Source -> IO ()
    buildSource src = do
        let folderName = src.name ++ "-" ++ src.version
        changeDir folderName
        case !readConfig of
            Right cfg => do
                let pkgName = cfg.package ++ "-" ++ replaceDotsWithDashes cfg.version
                buildDeps cfg
                changeDir folderName
                idrisPkgsDir <- (++ ("/.idris2/idris2-" ++ supportedIdrisVersion ++ "/")) <$> getHomeDir
                let installedPkgDir = idrisPkgsDir ++ pkgName
                when (not !(doesFileExist installedPkgDir)) $ do
                    install cfg
            Left err => putStrLn $ configErrorToString err
        changeDir ".."
        pure ()

    buildDeps : Config -> IO ()
    buildDeps cfg = do
        fetchDeps cfg
        depsDir <- (++ "/.sae/") <$> getHomeDir
        changeDir depsDir
        fetchDeps cfg
        traverse_ buildSource cfg.sources

evalCommand : Config -> Command -> IO ()
evalCommand cfg GenerateIpkg = generateIpkg cfg
evalCommand cfg FetchDeps = fetchDeps cfg
evalCommand cfg BuildDeps = buildDeps cfg
evalCommand cfg Build = build cfg
evalCommand cfg Install = install cfg
evalCommand _ _ = pure ()

evalConfig : Command -> Either ConfigError Config -> IO ()
evalConfig _ (Left configError) = putStrLn $ configErrorToString configError
evalConfig cmd (Right cfg) = evalCommand cfg cmd

export
runCommand : Command -> IO ()
runCommand Help = log usageInfo
runCommand cmd = evalConfig cmd !readConfig