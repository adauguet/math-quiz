module Evergreen.V14.Types exposing (..)

import Evergreen.V14.BestScores.Types
import Evergreen.V14.Lives
import Evergreen.V14.Multiplication
import Evergreen.V14.NonEmpty
import Evergreen.V14.Practice.Types
import Evergreen.V14.Score
import Lamdera
import Time


type GameOverState
    = Idle String
    | Submitting
    | Submitted


type AgainstTheClockState
    = Loading
    | Playing Evergreen.V14.Multiplication.Multiplication
    | GameOver GameOverState


type alias AgainstTheClockModel =
    { state : AgainstTheClockState
    , tables : Evergreen.V14.NonEmpty.NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClockModel
    | Lives Evergreen.V14.Lives.Model
    | Practice Evergreen.V14.Practice.Types.Model
    | BestScores Evergreen.V14.BestScores.Types.Model


type alias FrontendModel =
    { page : Page
    , tables : Evergreen.V14.NonEmpty.NonEmpty Int
    }


type alias BackendModel =
    List Evergreen.V14.Score.SavedScore


type AgainstTheClockMsg
    = GotMultiplication Evergreen.V14.Multiplication.Multiplication
    | Select Int
    | Tick
    | DidInputPlayer String
    | SubmitScore


type FrontendMsg
    = LivesMsg Evergreen.V14.Lives.Msg
    | AgainstTheClockMsg AgainstTheClockMsg
    | BestScoresMsg Evergreen.V14.BestScores.Types.Msg
    | PracticeMsg Evergreen.V14.Practice.Types.Msg
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
    | GotScoresTime Lamdera.ClientId Time.Posix


type AgainstTheClockToFrontEnd
    = SavedScore


type ToFrontend
    = SendScores (List Evergreen.V14.Score.SavedScore)
    | AgainstTheClockToFrontEnd AgainstTheClockToFrontEnd
