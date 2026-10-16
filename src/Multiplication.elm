module Multiplication exposing (..)

import NonEmpty exposing (NonEmpty)
import Random exposing (Generator)
import Random.List
import Set


type Multiplication
    = Multiplication Int Int (List Int)


generator : NonEmpty Int -> Generator Multiplication
generator nonEmpty =
    Random.map2 Tuple.pair (NonEmpty.generator nonEmpty) (Random.int 0 10)
        |> Random.andThen (\( a, b ) -> fromFactors a b)


fromFactors : Int -> Int -> Generator Multiplication
fromFactors a b =
    let
        unique =
            Set.fromList >> Set.toList
    in
    Random.List.shuffle (answers a b |> unique)
        |> Random.andThen (\list -> Random.List.shuffle (a * b :: (list |> List.take 3) |> unique))
        |> Random.map (\list -> Multiplication a b list)


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
        |> List.map abs
