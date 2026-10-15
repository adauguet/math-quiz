module Evergreen.V11.BestScores.Types exposing (..)

import Evergreen.V11.Score


type Model
    = Loading
    | Loaded (List Evergreen.V11.Score.SavedScore)


type Msg
    = GotScores (List Evergreen.V11.Score.SavedScore)
