module Sae.Config

import Control.Monad.ExceptIO
import Data.Maybe
import Data.List
import Js.Yaml
import Sae.Types
import System.File
import Language.JSON

ConfigIO : Type -> Type
ConfigIO = ExceptIO ConfigError

throwErr : ConfigError -> ConfigIO Config
throwErr err = throw err

stringFields : List String
stringFields =
    [ "package"
    , "version"
    , "target"
    , "authors"
    , "maintainers"
    , "license"
    , "brief"
    , "readme"
    , "homepage"
    , "sourceloc"
    , "bugtracker"
    , "executable"
    , "sourcedir"
    , "builddir"
    , "outputdir"
    ]

stringListFields : List String
stringListFields = ["depends", "modules"]

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

    name <- reqStringField "name" xs
    url <- reqStringField "url" xs

    let version = optStringField "version" xs
        commit = optStringField "commit" xs

    pure $ MkSource {name, url, version, commit}
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

    package <- reqStringField "package" xs
    version <- reqStringField "version" xs

    primIO $ putStrLn $ show xs

    let target = optStringField "target" xs
        authors = optStringField "authors" xs
        maintainers = optStringField "maintainers" xs
        license = optStringField "license" xs
        brief = optStringField "brief" xs
        readme = optStringField "readme" xs
        homepage = optStringField "homepage" xs
        sourceloc = optStringField "sourceloc" xs
        bugtracker = optStringField "bugtracker" xs
        executable = optStringField "executable" xs
        sourcedir = optStringField "sourcedir" xs
        builddir = optStringField "builddir" xs
        outputdir = optStringField "outputdir" xs
        depends = stringArrayField "depends" xs

    sources <- sourcesField xs

    pure $ MkConfig
        { package = package
        , version = version
        , target = target
        , authors = authors
        , maintainers = maintainers
        , license = license
        , brief = brief
        , readme = readme
        , homepage = homepage
        , sourceloc = sourceloc
        , bugtracker = bugtracker
        , executable = executable
        , sourcedir = sourcedir
        , builddir = builddir
        , outputdir = outputdir
        , depends = depends
        , modules = []
        , sources = sources
        }

mkConfig : ConfigIO Config
mkConfig = do
    eqFileContent <-
        case !(primIO $ readFile "Eq.yml") of
            Left err => throw $ Custom $ show err
            Right x => pure $ yamlToJson x

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
configErrorToString (UnknownField field) = "Unknown field: " ++ field
configErrorToString (TypeMismatch field expectedType) =
    "Type mismatch for the field " ++ field ++ ", expected " ++ expectedType
configErrorToString (RequiredFieldMissing field) = "Missing required " ++ field ++ " field"
configErrorToString ConfigFileShouldBeObject = "Config file should be an object"
configErrorToString (Custom s) = s
