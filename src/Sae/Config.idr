module Sae.Config

import Control.Monad.ExceptIO
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
stringListFields = ["depends", "modules", "sources"]

allowedFields : List String
allowedFields = stringFields ++ stringListFields

isJsonString : JSON -> Bool
isJsonString = \case
    JString _ => True
    _ => False

isJsonArrayOfStrings : JSON -> Bool
isJsonArrayOfStrings = \case
    JArray xs => all isJsonString xs
    _ => False

checkFieldType : String -> JSON -> ConfigIO ()
checkFieldType field jsonVal = do
    when (elem field stringFields && not (isJsonString jsonVal)) $
        throw $ TypeMismatch field "string"

    when (elem field stringListFields && not (isJsonArrayOfStrings jsonVal)) $
        throw $ TypeMismatch field "string array"

checkField : (String, JSON) -> ConfigIO String
checkField (field, jsonVal) = do
    when (not $ elem field allowedFields) $
        throw $ UnknownField field

    checkFieldType field jsonVal

    pure field

reqStringField : String -> List (String, JSON) -> ConfigIO String
reqStringField field xs =
    case lookup field xs of
        Just (JString x) => pure x
        _ => throw $ RequiredFieldMissing field

optStringField : List (String, JSON) -> String -> Maybe String
optStringField xs field =
    case lookup field xs of
        Just (JString x) => Just x
        _ => Nothing

parseConfig : List (String, JSON) -> ConfigIO Config
parseConfig xs = do
    traverse_ (\field => checkField field) xs

    package <- reqStringField "package" xs
    version <- reqStringField "version" xs

    let f = optStringField xs
        target = f "target"
        authors = f "authors"
        maintainers = f "maintainers"
        license = f "license"
        brief = f "brief"
        readme = f "readme"
        homepage = f "homepage"
        sourceloc = f "sourceloc"
        bugtracker = f "bugtracker"
        executable = f "executable"
        sourcedir = f "sourcedir"
        builddir = f "builddir"
        outputdir = f "outputdir"

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
        , depends = []
        , modules = []
        , sources = []
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
