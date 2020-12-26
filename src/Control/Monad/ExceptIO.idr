module Control.Monad.ExceptIO

import Control.App

export
ExceptIO : Type -> Type -> Type
ExceptIO err result = State () () (err :: Init) => App (err :: Init) result

export
throwErr : err -> ExceptIO err result
throwErr err = Control.App.throw err

handleExceptIO : State () () Init => ExceptIO err result -> App Init (Either err result)
handleExceptIO exceptIO = handle exceptIO (pure . Right) (pure . Left)

export
runExceptIO : ExceptIO err result -> IO (Either err result)
runExceptIO exceptIO = run $ new () $ handleExceptIO exceptIO
