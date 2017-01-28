module NewBasic exposing (..)

import Html
import Keyboard.Extra
import Elmo8.Assets
import Elmo8.GL.Display
import Elmo8.Scene
import Elmo8.Pico8 as Pico8


type alias Model =
    { assets : Elmo8.Assets.Model
    , display : Elmo8.GL.Display.Model
    , scene : Elmo8.Scene.Model
    , player : Player
    , bird : Bird
    , hello : Hello
    , keyboardModel : Keyboard.Extra.Model
    }


type Msg
    = AssetMsg Elmo8.Assets.Msg
    | DisplayMsg Elmo8.GL.Display.Msg
    | KeyboardMsg Keyboard.Extra.Msg


type alias Player =
    { x : Int
    , y : Int
    , colour : Int
    , layer : Int
    , health : Int
    }


type alias Bird =
    { x : Int
    , y : Int
    , sprite : Int
    , textureKey : String
    , layer : Int
    }


type alias Hello =
    { x : Int
    , y : Int
    , colour : Int
    , text : String
    , layer : Int
    }


birdWatching : String
birdWatching =
    "birdwatching"


init : ( Model, Cmd Msg )
init =
    let
        ( assetModel, assetMsg ) =
            Elmo8.Assets.init

        ( updatedAssetModel, spriteMsg ) =
            Elmo8.Assets.loadTexture assetModel birdWatching [ "birdwatching.png" ]

        ( displayModel, displayMsg ) =
            Elmo8.GL.Display.init

        player =
            { x = 10, y = 10, colour = Pico8.peach, health = 100, layer = 1 }

        bird =
            { x = 60, y = 90, sprite = 0, layer = 0, textureKey = birdWatching }

        hello =
            { x = 10, y = 50, colour = Pico8.orange, text = "Hello World!", layer = 2 }

        ( keyboardModel, keyboardMsg ) =
            Keyboard.Extra.init

        scene =
            Elmo8.Scene.init

        updatedScene =
            { scene | renderables = renderLayers bird player hello }
    in
        { assets = updatedAssetModel
        , player = player
        , bird = bird
        , hello = hello
        , display = displayModel
        , scene = updatedScene
        , keyboardModel = keyboardModel
        }
            ! [ Cmd.map AssetMsg assetMsg
              , Cmd.map AssetMsg spriteMsg
              , Cmd.map DisplayMsg displayMsg
              , Cmd.map KeyboardMsg keyboardMsg
              ]


renderLayers : Bird -> Player -> Hello -> Elmo8.Scene.Renderables
renderLayers bird player hello =
    Elmo8.Scene.layersToRenderables
        [ Elmo8.Scene.createLayer Elmo8.Scene.toSprite [ bird ]
        , Elmo8.Scene.createLayer Elmo8.Scene.toPixel [ player ]
        , Elmo8.Scene.createLayer Elmo8.Scene.toText [ hello ]
        ]


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

                wasd =
                    Keyboard.Extra.wasd keyboardModel

                player =
                    model.player

                updatedPlayer =
                    { player | x = player.x + arrows.x, y = player.y - arrows.y }

                bird =
                    model.bird

                updatedBird =
                    { bird | x = bird.x + wasd.x, y = bird.y - wasd.y }

                scene =
                    model.scene

                updatedScene =
                    { scene | renderables = renderLayers model.bird model.player model.hello }
            in
                { model
                    | player = updatedPlayer
                    , scene = updatedScene
                    , keyboardModel = keyboardModel
                    , bird = updatedBird
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
