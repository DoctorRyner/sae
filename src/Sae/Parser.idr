module Sae.Parser

import Data.String.Parser

newlines : Parser ()
newlines = skip $ many $ char '\n'

export
moduleDecl : Parser String
moduleDecl = do
    newlines
    string "module"
    spaces
    name <- takeWhile (/= '\n')
    pure name
