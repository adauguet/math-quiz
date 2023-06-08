module Frontend exposing (app)

import AgainstTheClock
import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Lamdera exposing (Url, UrlRequest)
import Lives
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Types exposing (FrontendModel, FrontendMsg(..), ToFrontend)


app :
    { init : Lamdera.Url -> Key -> ( Model, Cmd Msg )
    , view : Model -> Document Msg
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Cmd Msg )
    , subscriptions : Model -> Sub Msg
    , onUrlRequest : UrlRequest -> Msg
    , onUrlChange : Url -> Msg
    }
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view =
            \model ->
                { title = "Lamdera"
                , body = [ view model ]
                }
        }


type alias Model =
    FrontendModel


type alias Msg =
    FrontendMsg


init : Lamdera.Url -> Key -> ( Model, Cmd Msg )
init _ _ =
    ( { page = Types.Home
      , tables = NonEmpty.make 1 [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LivesMsg livesMsg ->
            case model.page of
                Types.Lives livesModel ->
                    let
                        ( m, cmd ) =
                            Lives.update livesMsg livesModel
                    in
                    ( { model | page = Types.Lives m }, Cmd.map LivesMsg cmd )

                _ ->
                    ( model, Cmd.none )

        AgainstTheClockMsg againstTheClockMsg ->
            case model.page of
                Types.AgainstTheClock againstTheClockModel ->
                    let
                        ( m, cmd ) =
                            AgainstTheClock.update againstTheClockMsg againstTheClockModel
                    in
                    ( { model | page = Types.AgainstTheClock m }, Cmd.map AgainstTheClockMsg cmd )

                _ ->
                    ( model, Cmd.none )

        ClickLives ->
            let
                ( m, cmd ) =
                    Lives.init model.tables
            in
            ( { model | page = Types.Lives m }, Cmd.map LivesMsg cmd )

        ClickAgainstTheClock ->
            let
                ( m, cmd ) =
                    AgainstTheClock.init model.tables
            in
            ( { model | page = Types.AgainstTheClock m }, Cmd.map AgainstTheClockMsg cmd )

        RemoveTable table ->
            case NonEmpty.filter (\x -> x /= table) model.tables of
                Just tables ->
                    ( { model | tables = tables }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        AddTable table ->
            let
                tables =
                    NonEmpty.append table model.tables
            in
            ( { model | tables = tables }, Cmd.none )

        ClickHome ->
            ( { model | page = Types.Home }, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        UrlClicked _ ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend _ model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Font.family [ Font.typeface "Bubblegum Sans" ]
        , Font.size 32
        , importFont "https://fonts.googleapis.com/css2?family=Bubblegum+Sans&family=VT323&display=swap"
        ]
    <|
        case model.page of
            Types.Home ->
                Element.column
                    [ Element.centerX
                    , Element.centerY
                    , Element.spacing 100
                    ]
                    [ tablesView model.tables
                    , Input.button
                        [ Border.width 1
                        , Border.rounded 3
                        , Element.paddingXY 12 6
                        ]
                        { onPress = Just ClickLives
                        , label = Element.text "3 vies"
                        }
                    , Input.button
                        [ Border.width 1
                        , Border.rounded 3
                        , Element.paddingXY 12 6
                        ]
                        { onPress = Just ClickAgainstTheClock
                        , label = Element.text "Contre la montre"
                        }
                    ]

            Types.Lives livesModel ->
                Lives.view
                    { toParentMsg = LivesMsg
                    , onClickRestart = ClickLives
                    , onClickHome = ClickHome
                    }
                    livesModel

            Types.AgainstTheClock againstTheClockModel ->
                AgainstTheClock.view
                    { toParentMsg = AgainstTheClockMsg
                    , onClickRestart = ClickAgainstTheClock
                    , onClickHome = ClickHome
                    }
                    againstTheClockModel

            Types.Settings ->
                Element.text "Settings"


tablesView : NonEmpty Int -> Element Msg
tablesView tables =
    Element.row
        [ Element.spacing 10 ]
        (List.map
            (\int ->
                let
                    attributes =
                        [ Element.width (Element.px 60)
                        , Element.height (Element.px 50)
                        , Border.rounded 5
                        , Font.center
                        , Font.size 24
                        , Font.color Element.white
                        ]
                in
                if NonEmpty.member int tables then
                    Input.button
                        (Background.color (Element.hsl 217 1 0.5) :: attributes)
                        { onPress = Just <| RemoveTable int
                        , label = Element.text <| String.fromInt int
                        }

                else
                    Input.button
                        (Background.color Element.gray :: attributes)
                        { onPress = Just <| AddTable int
                        , label = Element.text <| String.fromInt int
                        }
            )
            (List.range 1 10)
        )


importFont : String -> Attribute msg
importFont url =
    Html.node "style" [] [ Html.text <| "@import url('" ++ url ++ "')" ]
        |> Element.html
        |> Element.inFront


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Types.AgainstTheClock againstTheClockModel ->
            AgainstTheClock.subscriptions againstTheClockModel |> Sub.map AgainstTheClockMsg

        _ ->
            Sub.none
