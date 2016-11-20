module NewBasic exposing (..)

import AnimationFrame
import Html
import Time
import Clock

import Elmo8.Assets
import Elmo8.GL.Display
import Elmo8.Scene

type alias Model =
    { assets : Elmo8.Assets.Model
    , display : Elmo8.GL.Display.Model
    , scene : Elmo8.Scene.Model
    , player : Player
    , clock: Clock.Clock
    }

type Msg
    = AssetMsg Elmo8.Assets.Msg
    | DisplayMsg Elmo8.GL.Display.Msg
    | Tick Time.Time

type alias Player =
    { x : Int
    , y : Int
    , colour : Int
    , id : Int
    , layer : Int
    , health : Int
    }

birdWatching : String
birdWatching = "birdwatching"

init : (Model, Cmd Msg)
init =
    let
        (assetModel, assetMsg) = Elmo8.Assets.init
        (updatedAssetModel, spriteMsg) = Elmo8.Assets.loadTexture assetModel birdWatching ["birdwatching.png"]
        (displayModel, displayMsg) = Elmo8.GL.Display.init
        (scene, player) = Elmo8.Scene.addPixel Elmo8.Scene.init { x=10, y=10, colour=7, id=0, health=100, layer=0}
    in
        { assets = updatedAssetModel
        , player = player
        , display = displayModel
        , scene = scene
        , clock = Clock.withPeriod (1 * Time.second)
        }
        !
        [ Cmd.map AssetMsg assetMsg
        , Cmd.map AssetMsg spriteMsg
        , Cmd.map DisplayMsg displayMsg
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AssetMsg assetMsg ->
            let
                (updatedAssets, newMsg) = Elmo8.Assets.update assetMsg model.assets
            in
                { model | assets = updatedAssets} ! [ Cmd.map AssetMsg newMsg]
        DisplayMsg displayMsg ->
            let
                (updatedDisplay, newMsg) = Elmo8.GL.Display.update displayMsg model.display
            in
                { model | display = updatedDisplay} ! [ Cmd.map DisplayMsg newMsg]
        Tick time ->
            let
                (clock, _) = Clock.update (\_ m -> m) time model.clock model
            in
                { model | clock = clock} ! []

view : Model -> Html.Html Msg
view model =
    Html.div []
        [
        --   Html.div [] [ toString model |> Html.text ],
          Elmo8.Scene.render model.display model.assets model.scene
            |> Elmo8.GL.Display.view model.display
            |> Html.map DisplayMsg
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
    -- AnimationFrame.diffs (Tick << Time.inSeconds)
    Sub.none

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
