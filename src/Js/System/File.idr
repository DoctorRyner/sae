module Js.System.File

import System.File
import Data.List

%foreign "node:lambda:() => process.platform == 'win32' ? 1 : 0"
prim__isWindows : PrimIO Double

isWindows : IO Bool
isWindows = pure $ if !(primIO prim__isWindows) == 1
                   then True
                   else False

%foreign """
node:lambda:(path, data) => {
    try {
        require('fs').writeFileSync(path, data)
        return ''
    } catch(err) {
        return err
    }
}
"""
prim__writeFile : String -> String -> PrimIO String

writeFileWindowsCompatible : String -> String -> IO (Either String ())
writeFileWindowsCompatible path content =
    let error = !(primIO $ prim__writeFile path content)
    in pure $ if error == ""
              then Right ()
              else Left error

export
writeFileFixed : String -> String -> IO (Either String ())
writeFileFixed path content =
    if !isWindows
    then writeFileWindowsCompatible path content
    else pure $ case !(System.File.ReadWrite.writeFile path content) of
        Left err => Left $ show err
        Right x  => Right x

export
%foreign """
node:lambda:path => {
    try {
        return require('fs').readFileSync(path, 'utf-8')
    } catch(err) {
        return '@!ERR'.concat(err)
    }
}
"""
prim__readFile : String -> PrimIO String

readFileWindowsCompatible : String -> IO (Either String String)
readFileWindowsCompatible path =
    let output = !(primIO $ prim__readFile path)
    in pure $ if pack (take 5 $ unpack output) == "@!ERR"
              then Left $ pack $ drop 5 $ unpack output
              else Right output

export
readFileFixed : String -> IO (Either String String)
readFileFixed path =
    if !isWindows
    then readFileWindowsCompatible path
    else pure $ case !(System.File.ReadWrite.readFile path) of
        Left err => Left $ show err
        Right x  => Right x