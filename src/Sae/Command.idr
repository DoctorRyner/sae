module Sae.Command

import Data.Either
import Data.String
import Data.String.Extra
import Data.Maybe
import Data.List
import Js.Console
import Js.Glob
import Js.System
import Js.System.File
import Sae.Config
import Sae.Info
import Sae.Ipkg
import Sae.Types
import Sae.Utils
import System.Directory

usageInfo : String
usageInfo =
"""
sae — Idris 2 Build Tool v\{Sae.Info.version}

Usage: sae [command] [arg*]

Available commands:
  help                  Show usage info
  install-deps          Install dependencies
  reinstall-deps        Forcibly reinstall dependencies
  build                 Build project
  yarn                  Build project and resolve npm dependencies
  install               Register package in the system
  release               Compile project into a file
  repl                  Open REPL
  new                   Create a sae project
"""

-- generate-ipkg

generateIpkg : Config -> IO ()
generateIpkg cfg =
    let dir = fromMaybe "./" !currentDir
        ipkgFiles = !(getFileNames "*.ipkg")
        ipkgPath = dir ++ "/" ++ cfg.package ++ ".ipkg"
        ipkg = configToIpkg cfg
    in case !(writeFileFixed ipkgPath ipkg) of
        Left err => failMsg $ show err
        Right _ =>
            when (not $ cfg.package ++ ".ipkg" `elem` ipkgFiles) $
                putStrLn $ "Generated: " ++ ipkgPath

-- fetch

fetchSource : String -> Config -> Source -> IO ()
fetchSource depsDir cfg src = do
    let folderName = src.name ++ "-" ++ src.version
        cloneDestination = depsDir ++ folderName
        cloneCmd = "git clone " ++ src.url ++ " " ++ cloneDestination
        changeVersionCmd = "git -c advice.detachedHead=false checkout " ++ src.version

    _ <- changeDir cfg.projectDir

    when (not !(doesFileExist cloneDestination)) $ do
        if !(system cloneCmd) == 0
            then do
                _ <- changeDir cloneDestination
                if !(system changeVersionCmd) == 0
                    then ignore $ do
                        -- when (elem cfg.target ["javascript", "node"] && !(doesFileExist "package.json")) $ do
                        --     yarnVersionCmdResult <- system "yarn --version"
                        --     system $ if yarnVersionCmdResult == 0 then "yarn" else "npm i"
                        --     pure ()
                        changeDir ".."
                    else failMsg $ "Couldn't switch to version: " ++ changeVersionCmd
            else failMsg $ "Cloning failed: " ++ cloneCmd

fetchDeps : Config -> IO ()
fetchDeps cfg = do
    let saeDir      = !getHomeDir ++ "/.sae/"
        depsRootDir = saeDir ++ "deps/"
        depsDir     = depsRootDir ++ "idris-" ++ cfg.langVersion ++ "/"

    traverse_ createDir [saeDir, depsRootDir, depsDir]
    traverse_ (fetchSource depsDir cfg) cfg.sources

mutual
    -- install-deps / reinstall-deps

    installSource : Bool -> Source -> IO ()
    installSource shouldRebuild src = do
        let folderName = src.name ++ "-" ++ src.version
        _ <- changeDir folderName
        case !readConfig of
            Right cfg => do
                let pkgName         = cfg.package ++ "-" ++ cfg.version
                    installedPkgDir = cfg.pkgsDir ++ "/" ++ pkgName
                installDeps shouldRebuild cfg
                _ <- changeDir folderName
                installedPkgDirDoesntExist <- not <$> doesFileExist installedPkgDir
                when (shouldRebuild || installedPkgDirDoesntExist) $
                    install cfg
            Left err => failMsg $ configErrorToString err
        _ <- changeDir ".."
        pure ()

    installDeps : Bool -> Config -> IO ()
    installDeps shouldRebuild cfg = do
        let depsDir = !getHomeDir ++ "/.sae/deps/idris-" ++ cfg.langVersion ++ "/"
        fetchDeps cfg
        _ <- changeDir depsDir
        traverse_ (installSource shouldRebuild) cfg.sources

    -- build

    build : Config -> IO ()
    build cfg = do
        initialDir <- fromMaybe "" <$> currentDir
        generateIpkg cfg
        installDeps False cfg
        _ <- changeDir initialDir
        _ <- system $ "idris2 --build " ++ cfg.package ++ ".ipkg"
        pure ()

    -- install

    install : Config -> IO ()
    install cfg = do
        initialDir <- fromMaybe "" <$> currentDir
        putStrLn $ "package: " ++ cfg.package ++ "-" ++ cfg.version
        generateIpkg cfg
        installDeps False cfg
        _ <- changeDir initialDir
        _ <- system $ "idris2 --install " ++ cfg.package ++ ".ipkg"
        pure ()

-- new

mkEqFile : String -> String
mkEqFile projectName =
"""
package: \{projectName}
version: 0.0.1

# depends:
# - contrib

# sources:
# - name: some-package
#   url: https://github.com/SomeAuthor/some-repository
#   version: v0.0.1
"""

basicMainFile : String
basicMainFile =
"""
module Main

main : IO ()
main = putStrLn "Now, I'm gonna solve all of the equations!"
"""

new : String -> IO ()
new projectName = do
    _ <- createDir projectName
    _ <- changeDir projectName
    _ <- createDir "src"
    _ <- writeFileFixed "Eq.yml" $ mkEqFile projectName
    _ <- writeFileFixed "src/Main.idr" basicMainFile
    _ <- writeFileFixed ".gitignore" $ unlines ["build/", "DS_Store", projectName ++ ".ipkg"]
    pure ()

-- release

release : Config -> IO ()
release cfg = do
    build cfg

    let outputFileName = if elem cfg.target ["javascript", "node"] then "index.js" else cfg.package
        releaseCmd = join " "
            [ "idris2"
            , cfg.sourcedir ++ "/Main.idr"
            , "--codegen " ++ cfg.target
            , concatMap (" -p " ++) cfg.depends
            , "-o " ++ outputFileName
            ]
        releaseCmdResultCode = !(system releaseCmd)
        projectPath = fromMaybe "" !currentDir
        outputMsg =
            if releaseCmdResultCode == 0
            then Right $ "Compiled: " 
                      ++ projectPath
                      ++ (fromMaybe "/build" cfg.builddir)
                      ++ "/exec/" ++ outputFileName
            else Left $ "ERROR(" ++ show releaseCmdResultCode ++ "): Couldn't built " ++ cfg.package

    either failMsg putStrLn outputMsg

-- run

run : List String -> Config -> IO ()
run args cfg = do
    let outputFileName = if elem cfg.target ["javascript", "node"] then "index.js" else cfg.package
        projectPath = fromMaybe "" !currentDir
        outputFilePath = projectPath ++ (fromMaybe "/build" cfg.builddir) ++ "/exec/" ++ outputFileName
        runCmd =
            if cfg.target == "node"
            then "node " ++ outputFilePath ++ " " ++ join " " args
            else outputFilePath ++ " " ++ join " " args

    _ <- system runCmd
    pure ()

-- repl

repl : Config -> IO ()
repl cfg = do
    initialDir <- fromMaybe "" <$> currentDir
    generateIpkg cfg
    installDeps False cfg
    _ <- changeDir initialDir

    let idrisReplCmd = "idris2 --repl \{cfg.package}.ipkg"
        rlwrapVersionCmdResult = !(systemStr "rlwrap --version")
        replCmd =
            if isRight rlwrapVersionCmdResult
            then "rlwrap " ++ idrisReplCmd
            else idrisReplCmd

    when (isLeft rlwrapVersionCmdResult) $
        putStrLn "WARNING! Install 'rlwrap' to get history and improve your repl experience"
    _ <- system replCmd
    pure ()

-- yarn

createMergedPackageJson : String -> Config -> IO ()
createMergedPackageJson initialDir cfg = do
    let saeDir      = !getHomeDir ++ "/.sae/"
        depsRootDir = saeDir ++ "deps/"
        depsDir     = depsRootDir ++ "idris-" ++ cfg.langVersion ++ "/"
        depsPaths   =
            map (\src => depsDir ++ src.name ++ "-" ++ src.version ++ "/package.json")
                cfg.sources
    
    jsDepsPaths <-
        traverse
            (\path => pure (path, !(doesFileExist path)))
            depsPaths

    let verifiedPackageJsonPaths = map fst $ filter snd jsDepsPaths

    case !(readFileFixed "\{initialDir}/package.json") of
        Left err => pure ()
        Right basePackageJson => do
            _ <- changeDir initialDir
            _ <- system "yarn"
            _ <- system $ "npx package-json-merge package.json "
                       ++ join " " verifiedPackageJsonPaths
                       ++ " > build/package.json"
            _ <- system "cd build && yarn --production"
            pure ()

yarn : Config -> IO ()
yarn cfg =
    if cfg.target `elem` ["node", "javascript"]
    then do
        initialDir <- fromMaybe "" <$> currentDir
        build cfg
        createMergedPackageJson initialDir cfg
    else failMsg "yarn isn't supported for \{cfg.target} target, use node or javascript"

evalCommand : Config -> Command -> IO ()
evalCommand cfg  GenerateIpkg  = generateIpkg cfg
evalCommand cfg  FetchDeps     = fetchDeps cfg
evalCommand cfg  InstallDeps   = installDeps False cfg
evalCommand cfg  ReinstallDeps = installDeps True cfg
evalCommand cfg  Build         = build cfg
evalCommand cfg  Install       = install cfg
evalCommand cfg  Release       = release cfg
evalCommand cfg  Repl          = repl cfg
evalCommand cfg (Run args)     = run args cfg
evalCommand cfg  Yarn          = yarn cfg
evalCommand _    Help          = failMsg "help command should be handled by the runCommand function"
evalCommand _   (New _)        = failMsg "new command should be handled by the runCommand function"

evalConfig : Command -> Either ConfigError Config -> IO ()
evalConfig _   (Left configError) = failMsg $ configErrorToString configError
evalConfig cmd (Right cfg)        = evalCommand cfg cmd

export
runCommand : Command -> IO ()
runCommand Help              = log usageInfo
runCommand (New projectName) = new projectName
runCommand cmd               = evalConfig cmd !readConfig
