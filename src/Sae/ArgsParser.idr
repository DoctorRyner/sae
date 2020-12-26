module Sae.ArgsParser

import Data.List
import public Sae.Types

argsToCommandImpl : List String -> Command
argsToCommandImpl _ = Help

export
argsToCommand : List String -> Command
argsToCommand = argsToCommandImpl . drop 1
