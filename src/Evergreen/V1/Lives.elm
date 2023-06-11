module Evergreen.V1.Lives exposing (..)

import Evergreen.V1.Multiplication
import Evergreen.V1.NonEmpty


type State
    = Loading
    | Playing Evergreen.V1.Multiplication.Multiplication
    | GameOver


type alias Model =
    { state : State
    , tables : Evergreen.V1.NonEmpty.NonEmpty Int
    , score : Int
    , lives : Int
    }


type Msg
    = GotMultiplication Evergreen.V1.Multiplication.Multiplication
    | Select Int
