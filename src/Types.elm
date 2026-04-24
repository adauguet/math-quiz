module Types exposing (..)

import BestScores.Types as BestScores
import Lamdera exposing (ClientId, Url, UrlRequest)
import Lives
import Multiplication exposing (Multiplication)
import NonEmpty exposing (NonEmpty)
import Score exposing (SavedScore)
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
    = Loading
    | Playing Multiplication
    | GameOver GameOverState


type GameOverState
    = Idle String
    | Submitting
    | Submitted


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
    | DidInputPlayer String
    | SubmitScore


type ToBackend
    = SaveScore String Int
    | GetScores


type BackendMsg
    = GotTime ClientId String Int Posix


type ToFrontend
    = SendScores (List SavedScore)
    | AgainstTheClockToFrontEnd AgainstTheClockToFrontEnd


type AgainstTheClockToFrontEnd
    = SavedScore
