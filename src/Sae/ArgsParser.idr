module Sae.ArgsParser

import Data.List
import public Sae.Types

export
argsToCommand : List String -> Command
argsToCommand = \case
    "generate-ipkg"::_ => GenerateIpkg
    "fetch"::_ => FetchDeps
    "build"::_ => Build
    "install"::_ => Install
    _ => Help
