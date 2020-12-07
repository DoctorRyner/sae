module Data.Json.Encode

import Data.Json.Types
import Data.String.Extra
import Data.Strings

mutual
  encodeTuple : (String, Value) -> String
  encodeTuple (key, val) = "\"" ++ key ++ "\": " ++ encode val

  export
  encode : Value -> String
  encode MkNull = "null"
  encode (MkBool x) = toLower $ show x
  encode (MkNumber x) = show x
  encode (MkString x) = "\"" ++ x ++ "\""
  encode (MkArray xs) = "[" ++ join ", " (map encode xs) ++ "]"
  encode (MkObject xs) = "{" ++ join ", " (map encodeTuple xs) ++ "}"
