module Elmo8.Layers.Pixels exposing (..)

{-| Pixel layer, suitable for putpixel and getpixel operations

The most basic layer, theoretically all you need :)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import Task
import WebGL
import Elmo8.Assets
import Elmo8.GL.Renderers
import Elmo8.Layers.Common exposing (CanvasSize, Vertex, makeProjectionMatrix)


type alias X =
    Int


type alias Y =
    Int


{-| An index into the palette, usually 0 - 15 for 16 colour palettes

-}
type alias PixelColour =
    Int


type alias Model =
    { pixels : Dict.Dict ( X, Y ) PixelColour
    , screenSize : Vec2
    , maybePalette : Maybe WebGL.Texture
    , pixelPalette : Dict.Dict PixelColour PixelColour
    , screenPalette : Dict.Dict PixelColour PixelColour
    , canvasSize : Vec2
    , paletteSize : Vec2
    , projectionMatrix : Mat4
    }


type Msg
    = SetPixel X Y PixelColour
    | TextureError WebGL.Error
    | TextureLoad WebGL.Texture
    | Clear


setPixel : Model -> Int -> Int -> PixelColour -> Model
setPixel model x y colour =
    { model | pixels = Dict.insert ( x, y ) colour model.pixels }


getPixel : Model -> Int -> Int -> PixelColour
getPixel model x y =
    Dict.get ( x, y ) model.pixels
        |> Maybe.withDefault 0


pixelPalette : Model -> PixelColour -> PixelColour -> Model
pixelPalette model from to =
    { model | pixelPalette = Dict.insert from to model.pixelPalette }


screenPalette : Model -> PixelColour -> PixelColour -> Model
screenPalette model from to =
    { model | screenPalette = Dict.insert from to model.screenPalette }


resetPalette : Model -> Model
resetPalette model =
    { model | screenPalette = Dict.empty, pixelPalette = Dict.empty }


corners : Dict.Dict ( X, Y ) PixelColour
corners =
    Dict.fromList
        [ ( ( 0, 0 ), 0 )
        , ( ( 127, 0 ), 1 )
        , ( ( 127, 127 ), 2 )
        , ( ( 0, 127 ), 3 )
        , ( ( 0, 126 ), 4 )
        , ( ( 63, 63 ), 5 )
        ]


init : CanvasSize -> ( Model, Cmd Msg )
init canvasSize =
    { pixels = Dict.empty
    , screenSize = vec2 128.0 128.0
    , maybePalette = Nothing
    , pixelPalette = Dict.empty
    , screenPalette = Dict.empty
    , canvasSize = vec2 canvasSize.width canvasSize.height
    , paletteSize = vec2 16.0 16.0
    , projectionMatrix = makeProjectionMatrix
    }
        ! [ Elmo8.Assets.loadPaletteMapTexture
                |> Task.attempt
                    (\result ->
                        case result of
                            Err err ->
                                TextureError err

                            Ok val ->
                                TextureLoad val
                    )
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPixel x y colour ->
            { model | pixels = Dict.insert ( x, y ) colour model.pixels } ! []

        Clear ->
            { model | pixels = Dict.empty } ! []

        TextureError error ->
            model ! []

        TextureLoad texture ->
            { model | maybePalette = Just texture } ! []


render : Model -> List WebGL.Renderable
render model =
    case model.maybePalette of
        Nothing ->
            []

        Just texture ->
            Dict.toList model.pixels
                |> List.filterMap (renderPixel model texture)


renderPixel : Model -> WebGL.Texture -> ( ( X, Y ), PixelColour ) -> Maybe WebGL.Renderable
renderPixel model texture ( ( x, y ), colour ) =
    Elmo8.GL.Renderers.renderPixel
        { resolution =
            model.screenSize
            -- , palette = { texture = texture, textureSize = model.paletteSize}
        , projectionMatrix = model.projectionMatrix
        , screenSize = model.canvasSize
        }
        { textures = Dict.fromList [ ( Elmo8.Assets.paletteKey, { texture = texture, textureSize = model.paletteSize } ) ]
        }
        { x = x
        , y = y
        , colour = colour
        }
