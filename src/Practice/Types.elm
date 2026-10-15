module Practice.Types exposing (..)

import Mistakes exposing (Mistakes)
import Multiplication exposing (Multiplication)
import NonEmpty exposing (NonEmpty)


type alias Model =
    { state : State
    , tables : NonEmpty Int
    , mistakes : Mistakes
    , answered : List ( Multiplication, Int )
    , debug : Bool
    }


type State
    = Loading
    | Playing PlayingState Multiplication
    | Finished


type PlayingState
    = Idle
    | Answered
        { answer : Int
        , since : Int
        , wait : Int
        }


type Msg
    = GotMultiplication Multiplication
    | Select Int
    | Next
    | GotTime Int
    | Restart
    | Finish
    | ToggleDebug
