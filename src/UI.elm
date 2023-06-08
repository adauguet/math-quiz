module UI exposing (button)

import Element exposing (Attribute, Color, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input


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
