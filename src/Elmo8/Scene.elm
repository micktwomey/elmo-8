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
import Result
import IntDict
import IntDict.Safe
import WebGL
import Elmo8.Assets
import Elmo8.GL.Renderers
import Elmo8.GL.Display


{-| Represents each renderable type, you don't normal instantiate these, instead use the helpers

These are mapped to different renderers in the backend.

-}
type Renderable
    = Pixel Int
    | Sprite String Int
    | Text String Int


type alias Layer =
    Int


type alias X =
    Int


type alias Y =
    Int


type alias Model =
    { idCounter : Int
    , idToRenderable : IntDict.IntDict ( Layer, X, Y )
    , renderables : Dict.Dict ( Layer, X, Y ) Renderable
    }


init : Model
init =
    { idCounter = 0
    , idToRenderable = IntDict.empty
    , renderables = Dict.empty
    }


clear : Model -> Model
clear model =
    init


getNextId : Model -> ( Model, Int )
getNextId model =
    let
        nextId =
            model.idCounter + 1
    in
        ( { model | idCounter = nextId }, nextId )


addPixel : Model -> { a | x : Int, y : Int, id: Int, layer : Int, colour: Int} -> (Model, { a | x : Int, y : Int, id : Int, layer : Int, colour: Int})
addPixel model pixel =
    let
        (updatedModel, id) = getNextId model
    in
        ( updatePixel updatedModel { x = pixel.x, y = pixel.y, colour = pixel.colour, layer=pixel.layer, id=id}
        , { pixel | id = id}
        )

addSprite : Model -> { a | x : Int, y : Int, id: Int, layer : Int, sprite: Int, textureKey: String} -> (Model, { a | x : Int, y : Int, id : Int, layer : Int, sprite: Int, textureKey: String})
addSprite model sprite =
    let
        (updatedModel, id) = getNextId model
        updatedSprite = {sprite | id = id}
    in
        ( updateSprite updatedModel updatedSprite
        , updatedSprite
        )

updateRenderable : Model -> { a | x : Int, y : Int, id : Int, layer : Int, renderable : Renderable } -> Model
updateRenderable model { x, y, id, layer, renderable } =
    let
        key = ( 0 - layer, x, y ) -- negate the layer to get them to sort the way we want (0 on the bottom)
    in
        case IntDict.get id model.idToRenderable of
            Just renderableKey ->
                case renderableKey == key of
                    True ->
                        model

                    False ->
                        { model
                            | renderables =
                                Dict.insert key renderable model.renderables
                                    |> Dict.remove renderableKey
                            , idToRenderable =
                                IntDict.Safe.safeInsert id key model.idToRenderable
                                    |> Result.withDefault model.idToRenderable
                        }

            Nothing ->
                { model
                    | renderables =
                        Dict.insert key renderable model.renderables
                    , idToRenderable =
                        IntDict.Safe.safeInsert id key model.idToRenderable
                            |> Result.withDefault model.idToRenderable
                }


updateSprite : Model -> { a | x : Int, y : Int, sprite : Int, layer : Int, id : Int, textureKey: String } -> Model
updateSprite model { x, y, textureKey, sprite, layer, id } =
    updateRenderable
        model
        { x = x
        , y = y
        , layer = layer
        , id = id
        , renderable = Sprite textureKey sprite
        }


updatePixel : Model -> { a | x : Int, y : Int, colour : Int, layer : Int, id : Int } -> Model
updatePixel model { x, y, colour, layer, id } =
    updateRenderable
        model
        { x = x
        , y = y
        , layer = layer
        , id = id
        , renderable = Pixel colour
        }


updateText : Model -> { a | x : Int, y : Int, text : String, colour : Int, layer : Int, id : Int } -> Model
updateText model { x, y, text, colour, layer, id } =
    updateRenderable
        model
        { x = x
        , y = y
        , layer = layer
        , id = id
        , renderable = Text text colour
        }


renderItem : Elmo8.GL.Display.Model -> Elmo8.Assets.Model -> ( ( Layer, X, Y ), Renderable ) -> Maybe WebGL.Renderable
renderItem display assets ( ( layer, x, y ), renderable ) =
    case renderable of
        Pixel colour ->
            Elmo8.GL.Renderers.renderPixel
                display
                assets
                { x = x
                , y = y
                , colour = colour
                }

        Sprite textureKey sprite ->
            Elmo8.GL.Renderers.renderSprite
                display
                assets
                { x = x
                , y = y
                , textureKey = textureKey
                , sprite = sprite
                }
        _ ->
            Nothing


{-| Render the scene to WebGL renderables
-}
render : Elmo8.GL.Display.Model -> Elmo8.Assets.Model -> Model -> List WebGL.Renderable
render display assets model =
    Dict.toList model.renderables
        |> List.filterMap (renderItem display assets)
