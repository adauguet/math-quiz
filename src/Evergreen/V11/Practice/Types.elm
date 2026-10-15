module Evergreen.V11.Practice.Types exposing (..)

import Evergreen.V11.Mistakes
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
    | Finished


type alias Model =
    { state : State
    , tables : Evergreen.V11.NonEmpty.NonEmpty Int
    , mistakes : Evergreen.V11.Mistakes.Mistakes
    , answered : List ( Evergreen.V11.Multiplication.Multiplication, Int )
    , debug : Bool
    }


type Msg
    = GotMultiplication Evergreen.V11.Multiplication.Multiplication
    | Select Int
    | Next
    | GotTime Int
    | Restart
    | Finish
    | ToggleDebug
