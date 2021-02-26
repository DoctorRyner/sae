module Js.Toml

export
%foreign "node:lambda:x => JSON.stringify(require('toml').parse(x))"
tomlToJson : String -> String
