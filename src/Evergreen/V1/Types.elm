module Evergreen.V1.Types exposing (..)

import Evergreen.V1.BestScores.Types
import Evergreen.V1.Lives
import Evergreen.V1.Multiplication
import Evergreen.V1.NonEmpty
import Evergreen.V1.Player
import Evergreen.V1.Score
import Lamdera
import Time


type AgainstTheClockState
    = Loading Evergreen.V1.Player.Player
    | ChoosePlayer
    | Playing Evergreen.V1.Player.Player Evergreen.V1.Multiplication.Multiplication
    | GameOver Evergreen.V1.Player.Player


type alias AgainstTheClockModel =
    { state : AgainstTheClockState
    , tables : Evergreen.V1.NonEmpty.NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClockModel
    | Lives Evergreen.V1.Lives.Model
    | BestScores Evergreen.V1.BestScores.Types.Model


type alias FrontendModel =
    { page : Page
    , tables : Evergreen.V1.NonEmpty.NonEmpty Int
    }


type alias BackendModel =
    List Evergreen.V1.Score.SavedScore


type AgainstTheClockMsg
    = GotMultiplication Evergreen.V1.Multiplication.Multiplication
    | Select Int
    | Tick
    | ClickedPlayer Evergreen.V1.Player.Player


type FrontendMsg
    = LivesMsg Evergreen.V1.Lives.Msg
    | AgainstTheClockMsg AgainstTheClockMsg
    | BestScoresMsg Evergreen.V1.BestScores.Types.Msg
    | ClickLives
    | ClickAgainstTheClock
    | ClickBestScores
    | RemoveTable Int
    | AddTable Int
    | ClickHome
    | UrlChanged Lamdera.Url
    | UrlClicked Lamdera.UrlRequest


type ToBackend
    = SaveScore Evergreen.V1.Score.Score
    | GetScores


type BackendMsg
    = GotTime Evergreen.V1.Score.Score Time.Posix


type ToFrontend
    = SendScores (List Evergreen.V1.Score.SavedScore)
