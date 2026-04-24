module Evergreen.V2.BestScores.Types exposing (..)

import Evergreen.V2.Score


type Model
    = Loading
    | Loaded (List Evergreen.V2.Score.SavedScore)


type Msg
    = GotScores (List Evergreen.V2.Score.SavedScore)
