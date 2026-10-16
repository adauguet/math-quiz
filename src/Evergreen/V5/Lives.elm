module Evergreen.V5.Lives exposing (..)

import Evergreen.V5.Multiplication
import Evergreen.V5.NonEmpty


type PlayingState
    = Idle
    | Answered
        { answer : Int
        , since : Int
        , wait : Int
        }


type State
    = Loading
    | Playing PlayingState Evergreen.V5.Multiplication.Multiplication
    | GameOver (Maybe String)


type alias Model =
    { state : State
    , tables : Evergreen.V5.NonEmpty.NonEmpty Int
    , answered : List ( Evergreen.V5.Multiplication.Multiplication, Int )
    }


type Msg
    = GotMultiplication Evergreen.V5.Multiplication.Multiplication
    | Select Int
    | Next
    | GotGameOverGif String
    | GotTime Int
