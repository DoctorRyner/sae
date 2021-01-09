module Sae.ArgsParser

import Data.List
import public Sae.Types

export
argsToCommand : List String -> Command
argsToCommand _ = Help
