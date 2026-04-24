module Evergreen.V2.Types exposing (..)

import Evergreen.V2.BestScores.Types
import Evergreen.V2.Lives
import Evergreen.V2.Multiplication
import Evergreen.V2.NonEmpty
import Evergreen.V2.Score
import Lamdera
import Time


type GameOverState
    = Idle String
    | Submitting
    | Submitted


type AgainstTheClockState
    = Loading
    | Playing Evergreen.V2.Multiplication.Multiplication
    | GameOver GameOverState


type alias AgainstTheClockModel =
    { state : AgainstTheClockState
    , tables : Evergreen.V2.NonEmpty.NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClockModel
    | Lives Evergreen.V2.Lives.Model
    | BestScores Evergreen.V2.BestScores.Types.Model


type alias FrontendModel =
    { page : Page
    , tables : Evergreen.V2.NonEmpty.NonEmpty Int
    }


type alias BackendModel =
    List Evergreen.V2.Score.SavedScore


type AgainstTheClockMsg
    = GotMultiplication Evergreen.V2.Multiplication.Multiplication
    | Select Int
    | Tick
    | DidInputPlayer String
    | SubmitScore


type FrontendMsg
    = LivesMsg Evergreen.V2.Lives.Msg
    | AgainstTheClockMsg AgainstTheClockMsg
    | BestScoresMsg Evergreen.V2.BestScores.Types.Msg
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
    = SendScores (List Evergreen.V2.Score.SavedScore)
    | AgainstTheClockToFrontEnd AgainstTheClockToFrontEnd
