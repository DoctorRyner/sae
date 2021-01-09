module Js.Yaml

import Js.FFI

export
%foreign (js "x => JSON.stringify(require('js-yaml').load(x, 'utf-8'))")
yamlToJson : String -> String
