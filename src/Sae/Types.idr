module Sae.Types

import Control.App
import Language.JSON

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
  version : Maybe String

public export
record Config where
  constructor MkConfig
  package,
  version,
  target,
  authors : String
  maintainers,
  license,
  brief,
  readme,
  homepage,
  sourceloc,
  bugtracker,
  executable,
  sourcedir,
  builddir,
  outputdir : Maybe String
  depends,
  modules,
  sources : List Source

public export
data ConfigError
     = UnknownField String
     | TypeMismatch String JSON JSON

public export
Show ConfigError where
     show (UnknownField field) = "UnknownField " ++ field
     show (TypeMismatch field expectedType actualType) =
       "TypeMissmatch " ++ field ++ " " ++ show expectedType ++ " " ++ show actualType
