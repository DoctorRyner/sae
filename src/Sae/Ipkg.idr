module Sae.Ipkg

import Data.String.Extra
import Data.List
import Sae.Types

infix 10 #

(#) : a -> b -> (a, b)
(#) = (,)

optField : (String, Maybe String) -> String
optField = \case
    (name, Just x) => name ++ " = " ++ x ++ "\n"
    _ => ""

export
replaceDotsWithDashes : String -> String
replaceDotsWithDashes = pack . map (\x => if x == '.' then '_' else x) . unpack

export
configToIpkg : Config -> String
configToIpkg cfg = concat
    [ "package " ++ cfg.package ++ "-" ++ replaceDotsWithDashes cfg.version
    , "\n\n"
    , "sourcedir = " ++ show cfg.sourcedir ++ "\n"
    , concatMap optField
        [ "authors" # cfg.authors
        , "maintainers" # cfg.maintainers
        , "license" # cfg.license
        , "brief" # cfg.brief
        , "readme" # cfg.readme
        , "homepage" # cfg.homepage
        , "sourceloc" # cfg.sourceloc
        , "bugtracker" # cfg.bugtracker
        , "executable" # cfg.executable
        , "builddir" # cfg.builddir
        , "outputdir" # cfg.outputdir
        ]
    , "\n"
    , if length cfg.depends == 0 
      then ""
      else "depends = " ++ join "\n        , " (map replaceDotsWithDashes cfg.depends) ++ "\n\n"
    , if length cfg.modules == 0
      then ""
      else "modules = " ++ join "\n        , " cfg.modules
    ]