module Evergreen.V11.Types exposing (..)

import Evergreen.V11.BestScores.Types
import Evergreen.V11.Lives
import Evergreen.V11.Multiplication
import Evergreen.V11.NonEmpty
import Evergreen.V11.Practice.Types
import Evergreen.V11.Score
import Lamdera
import Time


type GameOverState
    = Idle String
    | Submitting
    | Submitted


type AgainstTheClockState
    = Loading
    | Playing Evergreen.V11.Multiplication.Multiplication
    | GameOver GameOverState


type alias AgainstTheClockModel =
    { state : AgainstTheClockState
    , tables : Evergreen.V11.NonEmpty.NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClockModel
    | Lives Evergreen.V11.Lives.Model
    | Practice Evergreen.V11.Practice.Types.Model
    | BestScores Evergreen.V11.BestScores.Types.Model


type alias FrontendModel =
    { page : Page
    , tables : Evergreen.V11.NonEmpty.NonEmpty Int
    }


type alias BackendModel =
    List Evergreen.V11.Score.SavedScore


type AgainstTheClockMsg
    = GotMultiplication Evergreen.V11.Multiplication.Multiplication
    | Select Int
    | Tick
    | DidInputPlayer String
    | SubmitScore


type FrontendMsg
    = LivesMsg Evergreen.V11.Lives.Msg
    | AgainstTheClockMsg AgainstTheClockMsg
    | BestScoresMsg Evergreen.V11.BestScores.Types.Msg
    | PracticeMsg Evergreen.V11.Practice.Types.Msg
    | ClickLives
    | ClickAgainstTheClock
    | ClickPractice
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
    = SendScores (List Evergreen.V11.Score.SavedScore)
    | AgainstTheClockToFrontEnd AgainstTheClockToFrontEnd
