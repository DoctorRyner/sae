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

mutual
  ymlStr : Parser Value2
  ymlStr = do
    spaces
    MkString <$> takeWhile1 (/= '\n')

  arrItem : Parser Value2
  arrItem = do
    spaces
    char '-'
    spaces
    ymlVal

  ymlArr : Parser Value2
  ymlArr = do
    newlines
    MkArray <$> (ymlVal `sepBy` char '\n')

  export
  ymlVal : Parser Value2
  ymlVal = choice [ymlStr, ymlArr]
