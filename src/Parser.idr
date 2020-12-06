module Parser

import Data.String.Parser
import Data.Yaml

newlines : Parser ()
newlines = skip $ many $ char '\n'

yamlString : Parser Value
yamlString = do
  key <- takeWhile1 (/= ':')
  char ':'
  spaces1
  val <- takeWhile1 (/= '\n')
  newlines
  pure $ MkObject key val

export
yamlObject : Parser (List Value)
yamlObject = many yamlString

export
moduleDecl : Parser String
moduleDecl = do
  newlines
  string "module"
  spaces
  name <- takeWhile (/= '\n')
  pure name

export
strict : Parser a -> Parser a
strict = flip (<*) eos

mutual
  ymlObjItem : Parser (String, Value2)
  ymlObjItem = do
    key <- takeWhile1 (/= ':')
    char ':'
    val <- ymlVal
    pure (key, val)

  ymlObj : Parser Value2
  ymlObj = MkObject2 <$> many ymlObjItem

  ymlStr : Parser Value2
  ymlStr = do
    str <- takeWhile1 \c => c /= '\n' && c /= ':'
    char '\n'
    pure $ MkString str

  arrItem : Parser Value2
  arrItem = do
    char '-'
    spaces
    ymlVal

  ymlArr : Parser Value2
  ymlArr = do
    char '\n'
    MkArray <$> (arrItem `sepBy` char '\n')

  export
  ymlVal : Parser Value2
  ymlVal = choice [ymlArr, ymlStr, ymlObj]
