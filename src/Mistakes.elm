module Mistakes exposing (Mistakes, count, empty, generator, mostFrequent, record, weights)

import Dict exposing (Dict)
import Multiplication exposing (Multiplication)
import NonEmpty exposing (NonEmpty(..))
import Random exposing (Generator)


{-| Number of outstanding mistakes for each multiplication. Multiplications are
commutative: `( 4, 3 )` and `( 3, 4 )` share the same count.
-}
type alias Mistakes =
    Dict ( Int, Int ) Int


empty : Mistakes
empty =
    Dict.empty


key : ( Int, Int ) -> ( Int, Int )
key ( a, b ) =
    ( min a b, max a b )


count : ( Int, Int ) -> Mistakes -> Int
count pair mistakes =
    Dict.get (key pair) mistakes |> Maybe.withDefault 0


{-| A wrong answer makes the multiplication more frequent, a right one makes it
a bit less frequent, until it is back to normal.
-}
record : ( Int, Int ) -> Bool -> Mistakes -> Mistakes
record pair isCorrect mistakes =
    let
        newCount =
            if isCorrect then
                count pair mistakes - 1

            else
                count pair mistakes + 1
    in
    if newCount <= 0 then
        Dict.remove (key pair) mistakes

    else
        Dict.insert (key pair) newCount mistakes


weight : ( Int, Int ) -> Mistakes -> Float
weight pair mistakes =
    1 + 5 * toFloat (count pair mistakes)


{-| The weight of each multiplication from the given tables, as used by
`generator`. When both factors are among the tables, the multiplication is
only listed once, as `( a, b )` with `a <= b`.
-}
weights : Mistakes -> NonEmpty Int -> List ( Float, ( Int, Int ) )
weights mistakes tables =
    pairs tables
        |> List.map (\pair -> ( weight pair mistakes, pair ))


{-| Picks a multiplication from the given tables, favoring the ones with the
most mistakes. The same question can be asked several times in a row. When
both factors are among the tables, their order is random.
-}
generator : Mistakes -> NonEmpty Int -> Generator Multiplication
generator mistakes (NonEmpty table tables) =
    case weights mistakes (NonEmpty table tables) of
        first :: rest ->
            Random.weighted first rest
                |> Random.andThen
                    (\( a, b ) ->
                        if List.member b (table :: tables) then
                            Random.uniform ( a, b ) [ ( b, a ) ]

                        else
                            Random.constant ( a, b )
                    )
                |> Random.andThen (\( a, b ) -> Multiplication.fromFactors a b)

        [] ->
            Multiplication.generator (NonEmpty table tables)


pairs : NonEmpty Int -> List ( Int, Int )
pairs (NonEmpty table tables) =
    let
        all =
            table :: tables
    in
    all
        |> List.concatMap (\a -> List.map (\b -> ( a, b )) (List.range 1 10))
        |> List.filter (\( a, b ) -> not (isDuplicate all ( a, b )))


{-| Whether `( a, b )` is already covered by `( b, a )`.
-}
isDuplicate : List Int -> ( Int, Int ) -> Bool
isDuplicate tables ( a, b ) =
    b < a && List.member b tables


mostFrequent : Int -> Mistakes -> List ( ( Int, Int ), Int )
mostFrequent n mistakes =
    Dict.toList mistakes
        |> List.sortBy (\( _, c ) -> -c)
        |> List.take n
