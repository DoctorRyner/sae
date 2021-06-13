module Js.FFI

public export
js : String -> String
js = ("javascript:lambda:" ++)

public export
node : String -> String
node = ("node:lambda:" ++)

public export
browser : String -> String
browser = ("browser:lambda:" ++)

public export
req : String -> String -> String -> String
req path args body =
  "browser:lambda:"
    ++ args
    ++ " => "
    ++ "require('" ++ path ++ "')."
    ++ body

export
%foreign (js "(_a, _b, x) => x")
unsafeCoerce : a -> b

%foreign
    (js """
        time => {
            var waitTill = new Date(new Date().getTime() + time)
            while(waitTill > new Date()) {}
        }
    """)
prim__jsSleep : Double -> PrimIO ()

export
jsSleep : Double -> IO ()
jsSleep = primIO . prim__jsSleep