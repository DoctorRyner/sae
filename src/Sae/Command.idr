module Sae.Command

import Js.Console
import Sae.Info
import Sae.Types

import Data.String.Extra

availableCommands : List Command
availableCommands =
    [ Help
    ]

commandToString : Command -> String
commandToString Help = "help: Show usage info"

usageInfo : String
usageInfo =
    join "\n"
        $ [ "sae — Idris 2 Build Tool"
          , ""
          , "Version: " ++ version
          , ""
          , "Usage: sae [command] [arg*]"
          , ""
          , "Available commands:"
          ]
        ++ map (("  " ++) . commandToString) availableCommands

export
runCommand : Command -> IO ()
runCommand Help = log usageInfo
