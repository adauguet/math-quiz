module Score exposing (SavedScore, Score)

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
