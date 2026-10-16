module Evergreen.V14.Practice.Types exposing (..)

import Evergreen.V14.Mistakes
import Evergreen.V14.Multiplication
import Evergreen.V14.NonEmpty


type PlayingState
    = Idle
    | Answered
        { answer : Int
        , since : Int
        , wait : Int
        }


type State
    = Loading
    | Playing PlayingState Evergreen.V14.Multiplication.Multiplication
    | Finished


type alias Model =
    { state : State
    , tables : Evergreen.V14.NonEmpty.NonEmpty Int
    , mistakes : Evergreen.V14.Mistakes.Mistakes
    , answered : List ( Evergreen.V14.Multiplication.Multiplication, Int )
    , debug : Bool
    }


type Msg
    = GotMultiplication Evergreen.V14.Multiplication.Multiplication
    | Select Int
    | Next
    | GotTime Int
    | Restart
    | Finish
    | ToggleDebug
