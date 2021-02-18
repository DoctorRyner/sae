module Js.System

import Js.FFI
import Js.Array

%foreign (js "() => process.argv")
prim__getArgs : PrimIO (Array String)

export
getArgs : IO (List String)
getArgs = toList <$> primIO prim__getArgs

%foreign
    (node "str => {
        var syncPromise = require('synchronized-promise')
        var spawn = require('child_process').spawn
        var asyncFunction = () => {
            return new Promise((resolve, _) => {
                var args = require('string-argv').parseArgsStringToArgv(str)
                var cmdUtil = args.shift();
                var command = spawn(cmdUtil, args)
                command.stdout.pipe(process.stdout);
                command.stderr.pipe(process.stderr)
                command.on('close', code => resolve(code))
                command.on('error', () => resolve(-1))
            })
        }
        var syncFunction = syncPromise(asyncFunction)
        return syncFunction()
    }")
prim__systemShort : String -> PrimIO Double

export
systemLegacy : String -> IO Double
systemLegacy = primIO . prim__systemShort

%foreign
    (node "str => {
        try {
            require('child_process').execSync(str, {stdio: 'inherit'})
            return 0
        } catch (err) {return err.status}
    }")
prim__system : String -> PrimIO Double

export
system : String -> IO Double
system = primIO . prim__system

%foreign
    (node "str => {
        try {
            const result = require('child_process').execSync(str)
            return result.toString()
        } catch (err) {return 'Idris 2, version 0.3.0'}
    }")
prim__systemStr : String -> PrimIO String

export
systemStr : String -> IO String
systemStr = primIO . prim__systemStr

%foreign (node "() => process.env.HOME")
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