module Evergreen.V5.Types exposing (..)

import Evergreen.V5.BestScores.Types
import Evergreen.V5.Lives
import Evergreen.V5.Multiplication
import Evergreen.V5.NonEmpty
import Evergreen.V5.Score
import Lamdera
import Time


type GameOverState
    = Idle String
    | Submitting
    | Submitted


type AgainstTheClockState
    = Loading
    | Playing Evergreen.V5.Multiplication.Multiplication
    | GameOver GameOverState


type alias AgainstTheClockModel =
    { state : AgainstTheClockState
    , tables : Evergreen.V5.NonEmpty.NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClockModel
    | Lives Evergreen.V5.Lives.Model
    | BestScores Evergreen.V5.BestScores.Types.Model


type alias FrontendModel =
    { page : Page
    , tables : Evergreen.V5.NonEmpty.NonEmpty Int
    }


type alias BackendModel =
    List Evergreen.V5.Score.SavedScore


type AgainstTheClockMsg
    = GotMultiplication Evergreen.V5.Multiplication.Multiplication
    | Select Int
    | Tick
    | DidInputPlayer String
    | SubmitScore


type FrontendMsg
    = LivesMsg Evergreen.V5.Lives.Msg
    | AgainstTheClockMsg AgainstTheClockMsg
    | BestScoresMsg Evergreen.V5.BestScores.Types.Msg
    | ClickLives
    | ClickAgainstTheClock
    | ClickBestScores
    | RemoveTable Int
    | AddTable Int
    | ClickHome
    | UrlChanged Lamdera.Url
    | UrlClicked Lamdera.UrlRequest


type ToBackend
    = SaveScore String Int
    | GetScores


type BackendMsg
    = GotTime Lamdera.ClientId String Int Time.Posix


type AgainstTheClockToFrontEnd
    = SavedScore


type ToFrontend
    = SendScores (List Evergreen.V5.Score.SavedScore)
    | AgainstTheClockToFrontEnd AgainstTheClockToFrontEnd
