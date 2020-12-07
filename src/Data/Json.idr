module Data.Json

import public Data.Json.Types

import Data.String.Extra
import Data.String.Parser


mutual
  encodeTuple : (String, Value) -> String
  encodeTuple (key, val) = "\"" ++ key ++ "\": " ++ encode val

  export
  encode : Value -> String
  encode MkNull = "null"
  encode (MkBool x) = if x then "true" else "false"
  encode (MkNumber x) = show x
  encode (MkString x) = "\"" ++ x ++ "\""
  encode (MkArray xs) = "[" ++ join ", " (map encode xs) ++ "]"
  encode (MkObject xs) = "{" ++ join ", " (map encodeTuple xs) ++ "}"

jsonNull : Parser Value
jsonNull = MkNull <$ string "null"

jsonBool : Parser Value
jsonBool = choice [MkBool True <$ string "true", MkBool False <$ string "false"]

jsonNumber : Parser Value
jsonNumber = MkNumber <$> integer

jsonString : Parser Value
jsonString = do
  char '"'
  str <- takeWhile (/= '\"')
  char '"'
  pure $ MkString str

newlines : Parser ()
newlines = skip $ many $ char '\n'

strict : Parser a -> Parser a
strict = flip (<*) eos

sc : Parser ()
sc = skip $ many $ choice [space, satisfy (== '\t'), satisfy (== '\n')]

mutual
  jsonArray : Parser Value
  jsonArray = do
    sc
    char '['
    sc
    xs <- json `sepBy` (char ',' >> sc)
    sc
    char ']'
    sc
    pure $ MkArray xs

  jsonObjectItem : Parser (String, Value)
  jsonObjectItem = do
    sc
    char '"'
    key <- takeWhile1 (/= '"')
    string "\":"
    sc
    val <- json
    pure (key, val)

  jsonObject : Parser Value
  jsonObject = do
    sc
    char '{'
    xs <- jsonObjectItem `sepBy` (char ',' >> sc)
    sc
    char '}'
    pure $ MkObject xs

  json : Parser Value
  json = choice [jsonString, jsonNumber, jsonBool, jsonNull, jsonArray, jsonObject]

export
decode : String -> Either String Value
decode = either Left (Right . fst) . parse json
