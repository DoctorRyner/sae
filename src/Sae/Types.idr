module Sae.Types

import Control.App
import Language.JSON
import Data.String.Extra

-- Command

public export
data Command
    = Help

public export
Show Command where
    show Help = "Help"

-- Config

public export
record Source where
    constructor MkSource
    name,
    url : String
    commit,
    version : Maybe String

public export
Show Source where
    show source =
        "MkSource {"
            ++ join
                ", "
                [ "name: " ++ source.name
                , "url: " ++ source.url
                , "version: " ++ show source.version
                , "commit: " ++ show source.commit
                ]
            ++ "}"

public export
record Config where
    constructor MkConfig
    package,
    sourcedir,
    version : String
    target,
    authors,
    maintainers,
    license,
    brief,
    readme,
    homepage,
    sourceloc,
    bugtracker,
    executable,
    builddir,
    outputdir : Maybe String
    depends,
    modules : List String
    sources : List Source

public export
Show Config where
    show config =
        "MkConfig\n    { "
            ++ join
                "\n    , "
                [ "package: " ++ show config.package
                , "version: " ++ show config.version
                , "target: " ++ show config.target
                , "authors: " ++ show config.authors
                , "maintainers: " ++ show config.maintainers
                , "license: " ++ show config.license
                , "brief: " ++ show config.brief
                , "readme: " ++ show config.readme
                , "homepage: " ++ show config.homepage
                , "sourceloc: " ++ show config.sourceloc
                , "bugtracker: " ++ show config.bugtracker
                , "executable: " ++ show config.executable
                , "sourcedir: " ++ show config.sourcedir
                , "builddir: " ++ show config.builddir
                , "outputdir: " ++ show config.outputdir
                , "depends: " ++ show config.depends
                , "modules: " ++ show config.modules
                , "sources: " ++ show config.sources
                ]
            ++ "\n    }\n"

public export
data ConfigError
     = UnknownField String
     | TypeMismatch String String
     | RequiredFieldMissing String
     | ConfigFileShouldBeObject
     | Custom String
