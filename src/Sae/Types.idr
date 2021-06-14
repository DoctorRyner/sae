module Sae.Types

import Control.App
import Language.JSON
import Data.String.Extra

-- Command

public export
data Command
    = Help
    | GenerateIpkg
    | FetchDeps
    | InstallDeps
    | ReinstallDeps
    | Build
    | Install
    | Release
    | Repl
    | Run (List String)
    | New String

-- Config

public export
record Source where
    constructor MkSource
    name,
    url,
    version : String

public export
Show Source where
    show source =
        "MkSource {"
            ++ join
                ", "
                [ "name: " ++ source.name
                , "url: " ++ source.url
                , "version: " ++ source.version
                ]
            ++ "}"

public export
record Config where
    constructor MkConfig
    -- Direct ipkg fields
    package        : String        -- Is called name in ipkg
    version        : String
    authors        : Maybe String
    maintainers    : Maybe String
    license        : Maybe String
    brief          : Maybe String
    readme         : Maybe String
    homepage       : Maybe String
    sourceloc      : Maybe String
    bugtracker     : Maybe String
    depends        : List String
    modules        : List String   -- Can't be specified manually
    main           : Maybe String
    executable     : Maybe String
    sourcedir      : String        -- optional
    builddir       : Maybe String
    outputdir      : Maybe String
    prebuild       : Maybe String
    postbuild      : Maybe String
    preinstall     : Maybe String
    postinstall    : Maybe String
    preclean       : Maybe String
    postclean      : Maybe String
    -- Original fields
    langVersion    : String        -- Can't be specified manually
    pkgsDir        : String        -- Can't be specified manually
    projectDir     : String        -- Can't be specified manually
    target         : String        -- optional
    ignoredModules : List String
    sources        : List Source

public export
data ConfigError
     = UnknownField String
     | TypeMismatch String String
     | RequiredFieldMissing String
     | ConfigFileShouldBeObject
     | ReadingError String
