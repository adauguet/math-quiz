module Multiplication exposing (..)

import NonEmpty exposing (NonEmpty)
import Random exposing (Generator)
import Random.List
import Set


type Multiplication
    = Multiplication Int Int (List Int)


generator : NonEmpty Int -> Generator Multiplication
generator nonEmpty =
    let
        unique =
            Set.fromList >> Set.toList
    in
    Random.map2 (\table int -> ( table, int )) (NonEmpty.generator nonEmpty) (Random.int 1 10)
        |> Random.andThen
            (\( a, b ) ->
                Random.List.shuffle (answers a b |> unique)
                    |> Random.andThen (\list -> Random.List.shuffle (a * b :: (list |> List.take 3) |> unique))
                    |> Random.map (\list -> Multiplication a b list)
            )


answers : Int -> Int -> List Int
answers a b =
    [ a * b - 1
    , a * (b - 1)
    , a * (b + 1)
    , a * b + 1
    , a + b
    , (a - 1) * b
    , (a + 1) * b
    ]
