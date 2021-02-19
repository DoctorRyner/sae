module Sae.ArgsParser

import Data.List
import public Sae.Types

export
argsToCommand : List String -> Command
argsToCommand = \case
    "generate-ipkg" ::_    => GenerateIpkg
    "fetch"         ::_    => FetchDeps
    "install-deps"  ::_    => InstallDeps
    "reinstall-deps"::_    => ReinstallDeps
    "build"         ::_    => Build
    "install"       ::_    => Install
    "release"       ::_    => Release
    "repl"          ::_    => Repl
    "run"           ::xs   => Run xs
    "new"           ::x::_ => New x
    _                      => Help
