module Types exposing (..)

import BestScores.Types as BestScores
import Lamdera exposing (Url, UrlRequest)
import Lives
import Multiplication exposing (Multiplication)
import NonEmpty exposing (NonEmpty)
import Player exposing (Player)
import Score exposing (SavedScore, Score)
import Time exposing (Posix)


type alias FrontendModel =
    { page : Page
    , tables : NonEmpty Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClockModel
    | Lives Lives.Model
    | BestScores BestScores.Model


type alias AgainstTheClockModel =
    { state : AgainstTheClockState
    , tables : NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type AgainstTheClockState
    = Loading Player
    | ChoosePlayer
    | Playing Player Multiplication
    | GameOver Player


type alias BackendModel =
    List SavedScore


type FrontendMsg
    = LivesMsg Lives.Msg
    | AgainstTheClockMsg AgainstTheClockMsg
    | BestScoresMsg BestScores.Msg
    | ClickLives
    | ClickAgainstTheClock
    | ClickBestScores
    | RemoveTable Int
    | AddTable Int
    | ClickHome
    | UrlChanged Url
    | UrlClicked UrlRequest


type AgainstTheClockMsg
    = GotMultiplication Multiplication
    | Select Int
    | Tick
    | ClickedPlayer Player


type ToBackend
    = SaveScore Score
    | GetScores


type BackendMsg
    = GotTime Score Posix


type ToFrontend
    = SendScores (List SavedScore)
