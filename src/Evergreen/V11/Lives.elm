module Evergreen.V11.Lives exposing (..)

import Evergreen.V11.Multiplication
import Evergreen.V11.NonEmpty


type PlayingState
    = Idle
    | Answered
        { answer : Int
        , since : Int
        , wait : Int
        }


type State
    = Loading
    | Playing PlayingState Evergreen.V11.Multiplication.Multiplication
    | GameOver (Maybe String)


type alias Model =
    { state : State
    , tables : Evergreen.V11.NonEmpty.NonEmpty Int
    , answered : List ( Evergreen.V11.Multiplication.Multiplication, Int )
    }


type Msg
    = GotMultiplication Evergreen.V11.Multiplication.Multiplication
    | Select Int
    | Next
    | GotGameOverGif String
    | GotTime Int
