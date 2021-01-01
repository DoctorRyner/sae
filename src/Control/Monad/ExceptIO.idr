module Control.Monad.ExceptIO

import public Control.App
import public Control.App.Console

public export
ExceptIO : Type -> Type -> Type
ExceptIO err result = State () () (err :: Init) => App (err :: Init) result

handleExceptIO : State () () Init => ExceptIO err result -> App Init (Either err result)
handleExceptIO exceptIO = handle exceptIO (pure . Right) (pure . Left)

export
runExceptIO : ExceptIO err result -> IO (Either err result)
runExceptIO exceptIO = run $ new () $ handleExceptIO exceptIO
