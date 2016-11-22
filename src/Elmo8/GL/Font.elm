module Elmo8.GL.Font exposing (..)

import Math.Vector2 exposing (Vec2, vec2)
import Dict
import String
import Tuple
import WebGL
import Elmo8.GL.Characters exposing (Character, characterList)


type alias Vertex =
    { position : Vec2 }


type alias CharacterMeshes =
    Dict.Dict ( Int, Int ) (WebGL.Drawable Vertex)


defaultCharacter : Character
defaultCharacter =
    { characterWidth = 0
    , offsetX = 0
    , offsetY = 0
    , x = 0
    , y = 0
    , width = 0
    , height = 0
    }


meshWidthHeight : Float -> Float -> WebGL.Drawable Vertex
meshWidthHeight width height =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 width height), Vertex (vec2 width 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 height), Vertex (vec2 width height) )
        ]


meshesFromCharacters : CharacterMeshes
meshesFromCharacters =
    List.map (\( _, char ) -> ( ( char.width, char.height ), meshWidthHeight (toFloat char.width) (toFloat char.height) )) characterList
        |> Dict.fromList


fontMap : Dict.Dict Char Character
fontMap =
    Dict.fromList characterList


getCharacter : Dict.Dict Char Character -> Char -> Maybe Character
getCharacter characters char =
    Dict.get char characters


{-| Take a string at a certain position and convert to correctly positioned chars for rendering

-}
textToCharacters : { a | x : Int, y : Int, colour : Int, text : String } -> List { x : Int, y : Int, colour : Int, character : Character }
textToCharacters { x, y, colour, text } =
    String.toList text
        |> List.filterMap (getCharacter fontMap)
        |> List.scanl getNextPosition ( { x = x, y = y, colour = colour, character = defaultCharacter }, ( 0, 0 ) )
        |> List.map Tuple.first


getNextPosition : Character -> ( { a | x : Int, y : Int, colour : Int, character : Character }, ( Int, Int ) ) -> ( { a | x : Int, y : Int, colour : Int, character : Character }, ( Int, Int ) )
getNextPosition character ( result, ( previousOffsetX, previousOffsetY ) ) =
    let
        -- Pixels are doubled in font sprite sheet so halve them
        offsetX =
            (character.offsetX // 2)

        x =
            result.x + offsetX - previousOffsetX + (character.characterWidth // 2)

        offsetY =
            (character.offsetY // 2)

        y =
            result.y + offsetY - previousOffsetY
    in
        ( { result | x = x, y = y, character = character }, ( offsetX, offsetY ) )
