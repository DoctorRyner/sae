module Data.Json.Parser

import Data.Json.Types
import Data.String.Parser

-- Utility

sc : Parser ()
sc = skip $ many $ choice [space, satisfy (== '\t'), satisfy (== '\n')]

-- Primitive types

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

-- Complex types

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

-- Full parser

  export
  json : Parser Value
  json = choice [jsonString, jsonNumber, jsonBool, jsonNull, jsonArray, jsonObject]
