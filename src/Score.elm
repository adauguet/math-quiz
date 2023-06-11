module Score exposing (SavedScore, Score, byValue, compare)

import Player exposing (Player(..))
import Time exposing (Posix)


type alias Score =
    { player : Player
    , score : Int
    }


type alias SavedScore =
    { timestamp : Posix
    , score : Score
    }


byValue : SavedScore -> Int
byValue { score } =
    -score.score


compare : SavedScore -> SavedScore -> Order
compare a b =
    if a.score.score > b.score.score then
        GT

    else if a.score.score < b.score.score then
        LT

    else if Time.posixToMillis a.timestamp < Time.posixToMillis b.timestamp then
        GT

    else if Time.posixToMillis a.timestamp > Time.posixToMillis b.timestamp then
        LT

    else
        EQ
