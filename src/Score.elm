module Score exposing (SavedScore, byValue, compare)

import Time exposing (Posix)


type alias SavedScore =
    { timestamp : Posix
    , player : String
    , score : Int
    }


byValue : SavedScore -> Int
byValue { score } =
    -score


compare : SavedScore -> SavedScore -> Order
compare a b =
    if a.score > b.score then
        GT

    else if a.score < b.score then
        LT

    else if Time.posixToMillis a.timestamp < Time.posixToMillis b.timestamp then
        GT

    else if Time.posixToMillis a.timestamp > Time.posixToMillis b.timestamp then
        LT

    else
        EQ
