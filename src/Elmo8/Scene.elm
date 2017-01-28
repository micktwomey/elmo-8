module Elmo8.Scene exposing (..)

{-| A scene in your game

Holds all that parts you want to render (sprites and friends).

You can create multiple scenes and swap between them. You can even have multiple displays with different scenes.

Responsible for taking renderables and assets and producing WebGL renderables.

A scene consists of layers (numbered 0+) which are rendered in order.

In each layer there is a mapping of (x, y) to renderable.

The scene processes each layer from 0 onwards, and each item from (0,0) onwards, rendering from the bottom layer up
and from the top level pixel down and to the right.

No two entities can occupy the same layer and pixel, if you need to overlap (e.g. two sprites on each other) then
use multiple layers.

-}

import Dict
import WebGL
import Elmo8.Assets
import Elmo8.GL.Renderers
import Elmo8.GL.Display


{-| Represents each renderable type, you don't normal instantiate these, instead use the helpers

These are mapped to different renderers in the backend.

-}
type RenderableType
    = PixelRenderable Int
    | SpriteRenderable String Int
    | TextRenderable String Int


type alias Renderables =
    Dict.Dict ( Layer, X, Y ) RenderableType


type alias Pixel a =
    { a | x : Int, y : Int, layer : Int, colour : Int }


type alias Sprite a =
    { a | x : Int, y : Int, layer : Int, sprite : Int, textureKey : String }


type alias Text a =
    { a | x : Int, y : Int, text : String, colour : Int, layer : Int }


type alias Layer =
    Int


type alias X =
    Int


type alias Y =
    Int


type alias Model =
    { renderables : Dict.Dict ( Layer, X, Y ) RenderableType
    }


init : Model
init =
    { renderables = Dict.empty
    }


clear : Model -> Model
clear model =
    init


toPixel : Pixel a -> ( ( Layer, X, Y ), RenderableType )
toPixel { x, y, colour, layer } =
    ( ( layer, x, y ), PixelRenderable colour )


toSprite : Sprite a -> ( ( Layer, X, Y ), RenderableType )
toSprite { x, y, layer, textureKey, sprite } =
    ( ( layer, x, y ), SpriteRenderable textureKey sprite )


toText : Text a -> ( ( Layer, X, Y ), RenderableType )
toText { x, y, layer, text, colour } =
    ( ( layer, x, y ), TextRenderable text colour )


createLayer : ({ a | x : Int, y : Int, layer : Int } -> ( ( Layer, X, Y ), RenderableType )) -> List { a | x : Int, y : Int, layer : Int } -> List ( ( Layer, X, Y ), RenderableType )
createLayer converter renderables =
    List.map converter renderables


layersToRenderables : List (List ( ( Layer, X, Y ), RenderableType )) -> Dict.Dict ( Layer, X, Y ) RenderableType
layersToRenderables layers =
    List.map Dict.fromList layers
        |> List.foldl Dict.union Dict.empty


renderItem : Elmo8.GL.Display.Model -> Elmo8.Assets.Model -> ( ( Layer, X, Y ), RenderableType ) -> List (Maybe WebGL.Renderable)
renderItem display assets ( ( layer, x, y ), renderable ) =
    case renderable of
        PixelRenderable colour ->
            [ Elmo8.GL.Renderers.renderPixel
                display
                assets
                { x = x
                , y = y
                , colour = colour
                }
            ]

        SpriteRenderable textureKey sprite ->
            [ Elmo8.GL.Renderers.renderSprite
                display
                assets
                { x = x
                , y = y
                , textureKey = textureKey
                , sprite = sprite
                }
            ]

        TextRenderable text colour ->
            Elmo8.GL.Renderers.renderText
                display
                assets
                { x = x
                , y = y
                , colour = colour
                , text = text
                }


{-| Render the scene to WebGL renderables
-}
render : Elmo8.GL.Display.Model -> Elmo8.Assets.Model -> Model -> List WebGL.Renderable
render display assets model =
    Dict.toList model.renderables
        |> List.sortBy (\( ( l, x, y ), item ) -> ( -l, x, y ))
        |> List.concatMap (renderItem display assets)
        |> List.filterMap identity
