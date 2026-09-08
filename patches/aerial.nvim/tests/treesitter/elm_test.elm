module ElmTest exposing (..)

type Enum
    = This
    | That Int String

type alias TypeAlias =
    { this : Int
    , that : String
    }

value : Int
value = 42

fun : Int -> Int
fun i =
    let
        ( a, b, c ) = ( 1, 2, 3 )
        ret = i * a * b * c
    in
    ret
