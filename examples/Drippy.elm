module Drippy exposing (..)

{-| Drippy

Implementation of PICO-8's drippy example.

Gives you a cursor which lets you paint as you move it around.

Pixels drip at random from drawn pixels.

-}

import Dict
import Html
import Keyboard.Extra

import Elmo8.Assets
import Elmo8.Scene
import Elmo8.GL.Display

-- type alias Pixel = Elmo8.Scene.Pixel {}

type alias Pixels = Dict.Dict (Int, Int) Cursor

type alias Cursor = Elmo8.Scene.Pixel { value : Float }
-- type alias Cursor =
--     { x : Int
--     , y : Int
--     , layer : Int
--     , colour : Int
--     , value : Float
--     , id : Int
--     }

type alias Model =
    { assets : Elmo8.Assets.Model
    , display : Elmo8.GL.Display.Model
    , scene : Elmo8.Scene.Model
    , keyboardModel : Keyboard.Extra.Model
    , cursor : Cursor
    , pixels : Pixels
    }

type Msg
    = AssetMsg Elmo8.Assets.Msg
    | DisplayMsg Elmo8.GL.Display.Msg
    | KeyboardMsg Keyboard.Extra.Msg

init : ( Model, Cmd Msg )
init =
    let
        ( assetModel, assetMsg ) =
            Elmo8.Assets.init
        ( displayModel, displayMsg ) =
            Elmo8.GL.Display.init
        ( keyboardModel, keyboardMsg ) =
            Keyboard.Extra.init

        ( scene, cursor ) =
            Elmo8.Scene.addPixel Elmo8.Scene.init { x=64, y=64, value=8.0, colour=8, layer=1, id=0}

    in
        { assets = assetModel
        , display = displayModel
        , scene = scene
        , keyboardModel = keyboardModel
        , cursor = cursor
        , pixels = Dict.empty
        }
            ! [ Cmd.map AssetMsg assetMsg
              , Cmd.map DisplayMsg displayMsg
              , Cmd.map KeyboardMsg keyboardMsg
              ]

drawPixel : Elmo8.Scene.Model -> Cursor -> Pixels -> (Elmo8.Scene.Model, Pixels)
drawPixel scene pixel pixels =

    -- Dict.insert (pixel.x, pixel.y) pixel.colour pixels
    let
        maybePixel = Dict.get (pixel.x, pixel.y) pixels
        (updatedScene, newPixel) = case maybePixel of
            Just p ->
                (scene, { p | colour = pixel.colour })
            Nothing ->
                Elmo8.Scene.addPixel scene pixel
    in
        ( Elmo8.Scene.updatePixel updatedScene newPixel, Dict.insert (newPixel.x, newPixel.y) newPixel pixels )


renderPixels : Pixels -> Elmo8.Scene.Model -> Elmo8.Scene.Model
renderPixels pixels scene =
    Dict.values pixels
    |> List.foldl (\pixel scene -> Elmo8.Scene.updatePixel scene pixel) scene

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AssetMsg assetMsg ->
            let
                ( updatedAssets, newMsg ) =
                    Elmo8.Assets.update assetMsg model.assets
            in
                { model | assets = updatedAssets } ! [ Cmd.map AssetMsg newMsg ]

        DisplayMsg displayMsg ->
            let
                ( updatedDisplay, newMsg ) =
                    Elmo8.GL.Display.update displayMsg model.display
            in
                { model | display = updatedDisplay } ! [ Cmd.map DisplayMsg newMsg ]

        KeyboardMsg keyMsg ->
            let
                ( keyboardModel, keyboardCmd ) =
                    Keyboard.Extra.update keyMsg model.keyboardModel
                arrows =
                    Keyboard.Extra.arrows keyboardModel

                cursor = model.cursor
                -- TODO: change colour based on timer
                updatedValue = if cursor.value + 0.1 >= 16.0 then 8.0 else cursor.value + 0.1
                updatedCursor = { cursor | x = cursor.x + arrows.x, y = cursor.y - arrows.y, value = updatedValue, colour = round(updatedValue) }
                (updatedScene, updatedPixels) = drawPixel model.scene updatedCursor model.pixels
                finalScene = Elmo8.Scene.updatePixel updatedScene updatedCursor
                    |> renderPixels updatedPixels

            in
                { model
                    | keyboardModel = keyboardModel
                    , cursor = updatedCursor
                    , scene = finalScene
                    , pixels = updatedPixels
                }
                    ! [ Cmd.map KeyboardMsg keyboardCmd ]


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Elmo8.Scene.render model.display model.assets model.scene
            |> Elmo8.GL.Display.view model.display
            |> Html.map DisplayMsg
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map KeyboardMsg Keyboard.Extra.subscriptions
        ]

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
