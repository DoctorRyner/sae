module Sae.Utils

import Data.List

export
qts : String -> String
qts s = "\"" ++ s ++ "\""

export
replaceDotsWithUnderscores : String -> String
replaceDotsWithUnderscores = pack . replaceOn '.' '_' . unpack
