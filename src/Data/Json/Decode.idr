module Data.Json.Decode

import Data.Json.Parser
import Data.Json.Types
import Data.String.Parser

export
decode : String -> Either String Value
decode = either Left (Right . fst) . parse json
