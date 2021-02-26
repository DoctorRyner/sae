module Sae.Command

import Data.String
import Data.String.Extra
import Data.Maybe
import Data.List
import Js.Console
import Js.Glob
import Js.System
import Sae.Config
import Sae.Info
import Sae.Ipkg
import Sae.Types
import System.Directory
import Js.System.File

availableCommands : List Command
availableCommands =
    [ Help
    , InstallDeps
    , ReinstallDeps
    , Build
    , Install
    , Release
    , Repl
    , Run []
    , New ""
    ]

commandToString : Command -> String
commandToString = \case
    Help          => "help                  Show usage info"
    GenerateIpkg  => "generate-ipkg         Generates ipkg file"
    FetchDeps     => "fetch                 Fetch dependencies"
    InstallDeps   => "install-deps          Install dependencies"
    ReinstallDeps => "reinstall-deps        Forcibly reinstall dependencies"
    Build         => "build                 Build project"
    Install       => "install               Register package in the system"
    Release       => "release               Compile project into a file"
    Repl          => "repl                  Open REPL"
    Run _         => "run                   Run compiled file"
    New _         => "new                   Create a sae project"

usageInfo : String
usageInfo =
    join "\n"
        $ [ "sae — Idris 2 Build Tool" ++ " v" ++ version
          , ""
          , "Usage: sae [command] [arg*]"
          , ""
          , "Available commands:"
          ]
        ++ map (("  " ++) . commandToString) availableCommands

generateIpkg : Config -> IO ()
generateIpkg cfg =
    let dir = fromMaybe "./" !currentDir
        ipkgFiles = !(getFileNames "*.ipkg")
        ipkgPath = dir ++ "/" ++ cfg.package ++ ".ipkg"
        ipkg = configToIpkg cfg
    in case !(writeFile ipkgPath ipkg) of
        Left err => print err
        Right _ =>
            when (not $ cfg.package ++ ".ipkg" `elem` ipkgFiles) $
                putStrLn $ "Generated: " ++ ipkgPath

fetchSource : Config -> Source -> IO ()
fetchSource cfg src =
    let folderName = src.name ++ "-" ++ src.version
        cloneCmd = "git clone " ++ src.url ++ " " ++ folderName
        changeVersionCmd = "git -c advice.detachedHead=false checkout " ++ src.version
    in when (not !(doesFileExist folderName)) $ do
        when (!(system cloneCmd) == 0) $ do
            changeDir folderName
            system changeVersionCmd
            -- when (elem cfg.target ["javascript", "node"] && !(doesFileExist "package.json")) $ do
            --     yarnVersionCmdResult <- system "yarn --version"
            --     system $ if True then "yarn" else "npm i"
            --     pure ()
            changeDir ".."
            pure ()

fetchDeps : Config -> IO ()
fetchDeps cfg = do
    let saeDir      = !getHomeDir ++ "/.sae/"
        depsRootDir = saeDir ++ "deps/"
        depsDir     = depsRootDir ++ "idris-" ++ cfg.langVersion ++ "/"

    traverse_ createDir [saeDir, depsRootDir, depsDir]
    changeDir depsDir
    traverse_ (fetchSource cfg) cfg.sources

mutual
    installSource : Bool -> Source -> IO ()
    installSource shouldRebuild src = do
        let folderName = src.name ++ "-" ++ src.version
        changeDir folderName
        case !readConfig of
            Right cfg => do
                let pkgName         = cfg.package ++ "-" ++ replaceDotsWithDashes cfg.version
                    installedPkgDir = cfg.pkgsDir ++ "/" ++ pkgName
                installDeps shouldRebuild cfg
                changeDir folderName
                installedPkgDirDoesntExist <- not <$> doesFileExist installedPkgDir
                when (shouldRebuild || installedPkgDirDoesntExist) $
                    install cfg
            Left err => putStrLn $ configErrorToString err
        changeDir ".."
        pure ()

    installDeps : Bool -> Config -> IO ()
    installDeps shouldRebuild cfg = do
        let depsDir = !getHomeDir ++ "/.sae/deps/idris-" ++ cfg.langVersion ++ "/"
        fetchDeps cfg
        changeDir depsDir
        traverse_ (installSource shouldRebuild) cfg.sources

    build : Config -> IO ()
    build cfg = do
        initialDir <- fromMaybe "" <$> currentDir
        generateIpkg cfg
        installDeps False cfg
        changeDir initialDir
        system $ "idris2 --build " ++ cfg.package ++ ".ipkg"
        pure ()

    install : Config -> IO ()
    install cfg = do
        initialDir <- fromMaybe "" <$> currentDir
        putStrLn $ "package: " ++ cfg.package ++ "-" ++ cfg.version
        generateIpkg cfg
        installDeps False cfg
        changeDir initialDir
        system $ "idris2 --install " ++ cfg.package ++ ".ipkg"
        pure ()

mkEqFile : String -> String
mkEqFile projectName = join "\n"
    [ "package: " ++ projectName
    , "version: 0.0.1"
    , ""
    , "# depends:"
    , "# - contrib"
    , ""
    , "# sources:"
    , "# - name: some-package"
    , "#   url: https://github.com/SomeAuthor/some-repository"
    , "#   version: v0.0.1"
    ]

basicMainFile : String
basicMainFile = unlines
    ["module Main"
    , ""
    , "main : IO ()"
    , "main = putStrLn " ++ show "Now, I'm gonna solve all of the equations!"
    ]

new : String -> IO ()
new projectName = do
    createDir projectName
    changeDir projectName
    createDir "src"
    writeFile "Eq.yml" $ mkEqFile projectName
    writeFile "src/Main.idr" basicMainFile
    writeFile ".gitignore" $ unlines ["deps/", "build/", "DS_Store", projectName ++ ".ipkg"]
    pure ()

release : Config -> IO ()
release cfg = do
    build cfg

    let outputFileName = if elem cfg.target ["javascript", "node"] then "index.js" else cfg.package
        releaseCmd = join " "
            [ "idris2"
            , cfg.sourcedir ++ "/Main.idr"
            , "--codegen " ++ cfg.target
            , concatMap (" -p " ++) $ map replaceDotsWithDashes cfg.depends
            , "-o " ++ outputFileName
            ]
        releaseCmdResultCode = !(system releaseCmd)
        projectPath = fromMaybe "" !currentDir
        outputMsg =
            if releaseCmdResultCode == 0
            then "Compiled: " ++ projectPath ++ (fromMaybe "/build" cfg.builddir) ++ "/exec/" ++ outputFileName
            else "ERROR(" ++ show releaseCmdResultCode ++ "): Couldn't built " ++ cfg.package

    putStrLn outputMsg

run : List String -> Config -> IO ()
run args cfg = do
    let outputFileName = if elem cfg.target ["javascript", "node"] then "index.js" else cfg.package
        projectPath = fromMaybe "" !currentDir
        outputFilePath = projectPath ++ (fromMaybe "/build" cfg.builddir) ++ "/exec/" ++ outputFileName
        runCmd =
            if cfg.target == "node"
            then "node " ++ outputFilePath ++ " " ++ join " " args
            else outputFilePath ++ " " ++ join " " args

    system runCmd
    pure ()

repl : Config -> IO ()
repl cfg = do
    build cfg
    system $ "idris2 --repl " ++ cfg.package ++ ".ipkg"
    pure ()

evalCommand : Config -> Command -> IO ()
evalCommand cfg GenerateIpkg  = generateIpkg cfg
evalCommand cfg FetchDeps     = fetchDeps cfg
evalCommand cfg InstallDeps   = installDeps False cfg
evalCommand cfg ReinstallDeps = installDeps True cfg
evalCommand cfg Build         = build cfg
evalCommand cfg Install       = install cfg
evalCommand cfg Release       = release cfg
evalCommand cfg Repl          = repl cfg
evalCommand cfg (Run args)    = run args cfg
evalCommand _   _             = putStrLn "Impossible happened, there is an unhandled case in the runCommand function"

evalConfig : Command -> Either ConfigError Config -> IO ()
evalConfig _ (Left configError) = putStrLn $ configErrorToString configError
evalConfig cmd (Right cfg) = evalCommand cfg cmd

export
runCommand : Command -> IO ()
runCommand Help = log usageInfo
runCommand (New projectName) = new projectName
runCommand cmd = evalConfig cmd !readConfig
