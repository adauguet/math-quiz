module Evergreen.V1.Lives exposing (..)

import Evergreen.V1.Multiplication
import Evergreen.V1.NonEmpty


type PlayingState
    = Idle
    | Answered Int


type State
    = Loading
    | Playing PlayingState Evergreen.V1.Multiplication.Multiplication
    | GameOver (Maybe String)


type alias Model =
    { state : State
    , tables : Evergreen.V1.NonEmpty.NonEmpty Int
    , answered : List ( Evergreen.V1.Multiplication.Multiplication, Int )
    }


type Msg
    = GotMultiplication Evergreen.V1.Multiplication.Multiplication
    | Select Int
    | Next
    | GotGameOverGif String
