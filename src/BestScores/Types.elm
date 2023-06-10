module BestScores.Types exposing (..)

import Score exposing (SavedScore)


type alias Model =
    List SavedScore


type Msg
    = GotScores (List SavedScore)
