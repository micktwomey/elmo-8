module Elmo8.GL.Font exposing (..)

import Math.Vector2 exposing (Vec2, vec2)
import Dict
import WebGL

import Elmo8.GL.Characters exposing (Character, characterList)

type alias Vertex =
    { position : Vec2 }


type alias CharacterMeshes =
    Dict.Dict ( Int, Int ) (WebGL.Drawable Vertex)


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

-- textToCharacters : String -> List { a | x : Int, y : Int, colour : Int, character : Char }