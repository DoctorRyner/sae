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
