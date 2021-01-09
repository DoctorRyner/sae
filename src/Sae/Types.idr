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
  sourcedir,
  builddir,
  outputdir : Maybe String
  depends,
  modules : List String
  sources : List Source

public export
data ConfigError
     = UnknownField String
     | TypeMismatch String String
     | RequiredFieldMissing String
     | ConfigFileShouldBeObject
     | Custom String
