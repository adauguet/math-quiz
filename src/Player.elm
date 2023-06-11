module Player exposing (Player(..), toString)


type Player
    = Joseph
    | Thomas


toString : Player -> String
toString player =
    case player of
        Joseph ->
            "Joseph"

        Thomas ->
            "Thomas"
