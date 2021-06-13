module Js.System

import Data.List
import Js.FFI
import Js.Array

%foreign (js "() => process.argv")
prim__getArgs : PrimIO (Array String)

export
getArgs : IO (List String)
getArgs = toList <$> primIO prim__getArgs

%foreign
    (node """
    str => {
        try {
            require('child_process').execSync(str, {stdio: 'inherit'})
            return 0
        } catch (err) {return err.status}
    }
    """)
prim__system : String -> PrimIO Double

export
system : String -> IO Double
system = primIO . prim__system

%foreign
    (node """
    str => {
        try {
            const result = require('child_process').execSync(str)
            return result.toString()
        } catch (err) {return '@!ERR'.concat(err)}
    }
    """)
prim__systemStr : String -> PrimIO String

export
systemStr : String -> IO (Either String String)
systemStr cmd =
    let output = !(primIO $ prim__systemStr cmd)
    in pure $ if pack (take 5 $ unpack output) == "@!ERR"
              then Left $ pack $ drop 5 $ unpack output
              else Right output

%foreign (node "() => require('os').homedir()")
prim__getHomeDir : PrimIO String

export
getHomeDir : IO String
getHomeDir = primIO prim__getHomeDir

%foreign (node "path => require('fs').existsSync(path) ? 1 : 0")
prim__doesFileExist : String -> PrimIO Double

export
doesFileExist : String -> IO Bool
doesFileExist path = do
    opCode <- primIO $ prim__doesFileExist path
    pure $ if opCode == 1 then True else False