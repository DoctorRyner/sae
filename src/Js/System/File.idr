module Js.System.File

import Data.List

%foreign "node:lambda:(path, data) => {
    try {
        require('fs').writeFileSync(path, data)
        return ''
    } catch(err) {
        return err
    }
}"
prim__writeFile : String -> String -> PrimIO String

export
writeFile : String -> String -> IO (Either String ())
writeFile path content =
    let error = !(primIO $ prim__writeFile path content)
    in pure $ if error == ""
              then Right ()
              else Left error

export
%foreign "node:lambda:path => {
    try {
        return require('fs').readFileSync(path, 'utf-8')
    } catch(err) {
        return '@!ERR'.concat(err)
    }
}"
prim__readFile : String -> PrimIO String

export
readFile : String -> IO (Either String String)
readFile path =
    let output = !(primIO $ prim__readFile path)
    in pure $ if pack (take 5 $ unpack output) == "@!ERR"
              then Left $ pack $ drop 5 $ unpack output
              else Right output
