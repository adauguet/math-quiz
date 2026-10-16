module BestScores.Types exposing (..)

import Score exposing (SavedScore)


type Model
    = Loading
    | Loaded (List SavedScore)


type Msg
    = GotScores (List SavedScore)
