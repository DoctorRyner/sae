module Sae.Types

import public Control.App
import public Control.App.Console

import Control.App.Console
import Sae.Utils

public export
record Config where
  constructor MkConfig
  package,
  version,
  target,
  sourcedir : String
  depends,
  sources,
  modules : List String

public export
data Command
  = Help
  | New String
  | Build
  | Release
  | Install
  | Run
  | FetchDeps
  | BuildDeps
