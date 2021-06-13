module Sae.Config

import Control.Monad.ExceptIO
import Data.Maybe
import Data.List
import Data.String.Extra
import Js.Array
import Js.FFI
import Js.Glob
import Js.Nullable
import Js.System
import Js.Yaml
import Js.Toml
import Sae.Types
import Sae.Info
import System.Directory
import Js.System.File
import System
import Language.JSON

ConfigIO : Type -> Type
ConfigIO = ExceptIO ConfigError

throwErr : ConfigError -> ConfigIO Config
throwErr err = throw err

stringFields : List String
stringFields =
    [ "package"
    , "version"
    , "langVersion"
    , "target"
    , "authors"
    , "maintainers"
    , "license"
    , "brief"
    , "readme"
    , "homepage"
    , "sourceloc"
    , "bugtracker"
    , "main"
    , "executable"
    , "sourcedir"
    , "builddir"
    , "outputdir"
    , "prebuild"
    , "postbuild"
    , "preinstall"
    , "postinstall"
    , "preclean"
    , "postclean"
    ]

stringListFields : List String
stringListFields = ["depends", "modules", "ignoredModules"]

sourceFields : List String
sourceFields = ["name", "url", "version", "commit"]

allowedFields : List String
allowedFields = stringFields ++ stringListFields ++ ["sources"]

reqStringField : String -> List (String, JSON) -> ConfigIO String
reqStringField field xs =
    case lookup field xs of
        Just (JString x) => pure x
        _ => throw $ RequiredFieldMissing field

optStringField : String -> List (String, JSON) -> Maybe String
optStringField field xs =
    case lookup field xs of
        Just (JString x) => Just x
        _ => Nothing

isJsonString : JSON -> Bool
isJsonString = \case
    JString _ => True
    _ => False

isJsonArrayOfStrings : JSON -> Bool
isJsonArrayOfStrings = \case
    JArray xs => all isJsonString xs
    _ => False

checkSourceField : (String, JSON) -> ConfigIO ()
checkSourceField (field, jsonVal) = do
    when (not $ elem field sourceFields) $
        throw $ UnknownField field
    when (elem field sourceFields && not (isJsonString jsonVal)) $
        throw $ TypeMismatch field "string"

jsonToSource : JSON -> ConfigIO Source
jsonToSource (JObject xs) = do
    traverse_ (\field => checkSourceField field) xs

    name    <- reqStringField "name" xs
    url     <- reqStringField "url" xs
    version <- reqStringField "version" xs

    pure $ MkSource {name, url, version}
jsonToSource _ = throw $ TypeMismatch "sources" "another type"

isJsonSource : JSON -> Bool
isJsonSource = \case
    JObject obj => True
    _ => False

isJsonArrayOfSources : JSON -> Bool
isJsonArrayOfSources = \case
    JArray xs => all isJsonSource xs
    _ => False

sourcesField : List (String, JSON) -> ConfigIO (List Source)
sourcesField xs = do
    case lookup "sources" xs of
        (Just (JArray arr)) => traverse (\jsonVal => jsonToSource jsonVal) arr
        _ => pure []

checkField : (String, JSON) -> ConfigIO ()
checkField (field, jsonVal) = do
    when (not $ elem field allowedFields) $
        throw $ UnknownField field
    when (elem field stringFields && not (isJsonString jsonVal)) $
        throw $ TypeMismatch field "string"
    when (elem field stringListFields && not (isJsonArrayOfStrings jsonVal)) $
        throw $ TypeMismatch field "string array"

jsonListToStringList : List JSON -> List String
jsonListToStringList (JString x::xs) = x :: jsonListToStringList xs
jsonListToStringList (_::xs) = jsonListToStringList xs
jsonListToStringList [] = []

stringArrayField : String -> List (String, JSON) -> List String
stringArrayField field xs =
    case lookup field xs of
        Just (JArray ys) => jsonListToStringList ys
        _ => []

parseConfig : List (String, JSON) -> ConfigIO Config
parseConfig xs = do
    traverse_ (\field => checkField field) xs

    let package        = !(reqStringField "package" xs)
        version        = !(reqStringField "version" xs)
        authors        = optStringField "authors" xs
        maintainers    = optStringField "maintainers" xs
        license        = optStringField "license" xs
        brief          = optStringField "brief" xs
        readme         = optStringField "readme" xs
        homepage       = optStringField "homepage" xs
        sourceloc      = optStringField "sourceloc" xs
        bugtracker     = optStringField "bugtracker" xs
        depends        = stringArrayField "depends" xs
        main           = optStringField "main" xs
        executable     = optStringField "executable" xs
        sourcedir      = fromMaybe "src" $ optStringField "sourcedir" xs
        builddir       = optStringField "builddir" xs
        outputdir      = optStringField "outputdir" xs
        prebuild       = optStringField "prebuild" xs
        postbuild      = optStringField "postbuild" xs
        preinstall     = optStringField "preinstall" xs
        postinstall    = optStringField "postinstall" xs
        preclean       = optStringField "preclean" xs
        postclean      = optStringField "postclean" xs
        target         = fromMaybe "chez" $ optStringField "target" xs
        langVersion    =
            pack $
            take 5 $
            drop 17 $
            unpack
                !(primIO $
                  either
                    (const "Idris 2, version 0.3.0")
                    id
                    <$> systemStr "idris2 --version")
        pkgsDir        = !(primIO getHomeDir) ++ "/.idris2/idris2-" ++ langVersion
        projectDir     = case !(primIO currentDir) of
            Just dir => dir
            Nothing => ""
        ignoredModules = stringArrayField "ignoredModules" xs
        sources        = !(sourcesField xs)

        refineModuleString : String -> String
        refineModuleString xs =
            pack $ map (\c => if c == '/' then '.' else c)
                       (unpack $ dropLast 4 xs)

        isNotIgnored : String -> Bool
        isNotIgnored moduleName =
            case find (== moduleName) ignoredModules of
                Just _ => False
                Nothing => True

    modules <- primIO $ do
        _ <- changeDir sourcedir
        fileNames <- getFileNames "**/*.idr"
        _ <- changeDir ".."
        pure
            $ filter isNotIgnored
            $ map refineModuleString fileNames

    pure $ MkConfig
        { package, version, langVersion, target, authors, maintainers, license, brief, readme
        , homepage, sourceloc, bugtracker, executable, sourcedir, builddir, outputdir, depends
        , modules, main, sources, ignoredModules, pkgsDir, prebuild, postbuild, preinstall
        , postinstall, preclean, postclean, projectDir
        }

mkConfig : ConfigIO Config
mkConfig = do
    eqFileContent <-
        case !(primIO $ readFileFixed "Eq.yml") of
            Left _ => case !(primIO $ readFileFixed "Eq.toml") of
                Left err => throw $ ReadingError err
                Right x  => pure $ tomlToJson x
            Right x  => pure $ yamlToJson x
    objectContent <-
        case parse eqFileContent of
            Just (JObject xs) => pure xs
            _ => throw ConfigFileShouldBeObject

    parseConfig objectContent

export
readConfig : IO (Either ConfigError Config)
readConfig = runExceptIO mkConfig

export
configErrorToString : ConfigError -> String
configErrorToString = \case
    UnknownField field              => "Unknown field: " ++ show field
    TypeMismatch field expectedType => "Type mismatch for the field " ++ field ++ ", expected "
                                                                               ++ show expectedType
    RequiredFieldMissing field      => "Missing required " ++ show field ++ " field"
    ConfigFileShouldBeObject        => "Config file should be an object"
    ReadingError err                => "Couldn't read Eq.{yml,toml}: " ++ err
