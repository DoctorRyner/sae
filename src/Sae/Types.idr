module Sae.Types

import Control.App
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
  modules : List String


public export
data Command
  = Help
  | New String
  | Build
  | Release
  -- | Install
  -- | Run

public export
data AppError = Custom String

public export
Show AppError where
  show (Custom x) = "Custom " ++ qts (show x)

public export
record AppState where
  constructor MkAppState
  cfg : Config

-- export
-- AppIO : Type -> Type
-- AppIO = App [AppError]

public export
AppIO : Type -> Type
AppIO a = (Console (AppError :: Init), State () AppState (AppError :: Init)) => App (AppError :: Init) a
