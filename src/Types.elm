module Types exposing (..)

import AgainstTheClock
import Lamdera exposing (Url, UrlRequest)
import Lives
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)


type alias FrontendModel =
    { page : Page
    , tables : NonEmpty Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClock.Model
    | Lives Lives.Model
    | Settings


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = LivesMsg Lives.Msg
    | AgainstTheClockMsg AgainstTheClock.Msg
    | ClickLives
    | ClickAgainstTheClock
    | RemoveTable Int
    | AddTable Int
    | ClickHome
    | UrlChanged Url
    | UrlClicked UrlRequest


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
