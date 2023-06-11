module UI exposing (blueButton, grayButton, greenButton, redButton)

import Element exposing (Attribute, Color, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input


greenButton : List (Attribute msg) -> { onPress : msg, label : String } -> Element msg
greenButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = Element.hsl 130 1 0.38
        , shadowColor = Element.hsl 130 1 0.28
        }


blueButton : List (Attribute msg) -> { onPress : msg, label : String } -> Element msg
blueButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = Element.hsl 212 1 0.47
        , shadowColor = Element.hsl 207 1 0.32
        }


redButton : List (Attribute msg) -> { onPress : msg, label : String } -> Element msg
redButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = Element.hsl 345 1 0.47
        , shadowColor = Element.hsl 340 1 0.32
        }


grayButton : List (Attribute msg) -> { onPress : msg, label : String } -> Element msg
grayButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = Element.hsl 0 0 0.5
        , shadowColor = Element.hsl 0 0 0.3
        }


button :
    List (Attribute msg)
    ->
        { onPress : msg
        , label : String
        , backgroundColor : Color
        , shadowColor : Color
        }
    -> Element msg
button attributes { onPress, label, backgroundColor, shadowColor } =
    Input.button
        ([ Font.size 32
         , Font.center
         , Border.rounded 12
         , Element.paddingXY 24 12
         , Background.color backgroundColor
         , Font.color <| Element.white
         , Element.mouseOver
            [ Element.moveUp 2
            , Border.shadow
                { offset = ( 0, 6 )
                , size = 0
                , blur = 0
                , color = shadowColor
                }
            ]
         , Border.shadow
            { offset = ( 0, 4 )
            , size = 0
            , blur = 0
            , color = shadowColor
            }
         ]
            ++ attributes
        )
        { onPress = Just onPress
        , label = Element.text label
        }
