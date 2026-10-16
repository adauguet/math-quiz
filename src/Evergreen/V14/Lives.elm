module Evergreen.V14.Lives exposing (..)

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
    | GameOver (Maybe String)


type alias Model =
    { state : State
    , tables : Evergreen.V14.NonEmpty.NonEmpty Int
    , answered : List ( Evergreen.V14.Multiplication.Multiplication, Int )
    }


type Msg
    = GotMultiplication Evergreen.V14.Multiplication.Multiplication
    | Select Int
    | Next
    | GotGameOverGif String
    | GotTime Int
