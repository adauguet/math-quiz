module Evergreen.V2.Lives exposing (..)

import Evergreen.V2.Multiplication
import Evergreen.V2.NonEmpty


type PlayingState
    = Idle
    | Answered Int


type State
    = Loading
    | Playing PlayingState Evergreen.V2.Multiplication.Multiplication
    | GameOver (Maybe String)


type alias Model =
    { state : State
    , tables : Evergreen.V2.NonEmpty.NonEmpty Int
    , answered : List ( Evergreen.V2.Multiplication.Multiplication, Int )
    }


type Msg
    = GotMultiplication Evergreen.V2.Multiplication.Multiplication
    | Select Int
    | Next
    | GotGameOverGif String
