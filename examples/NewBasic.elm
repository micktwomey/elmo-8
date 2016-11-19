module NewBasic exposing (..)

import Html
import Elmo8.Assets

type alias Model =
    { assets : Elmo8.Assets.Model
    , player : Player
    }

type Msg = AssetMsg Elmo8.Assets.Msg

type alias Player =
    { x : Int
    , y : Int
    , sprite : Int
    , texture : String
    , health : Int
    }

birdWatching : String
birdWatching = "birdwatching"

init : (Model, Cmd Msg)
init =
    let
        (assetModel, assetMsg) = Elmo8.Assets.init
        (updatedAssetModel, spriteMsg) = Elmo8.Assets.loadTexture assetModel birdWatching ["birdwatching.png"]
    in
        { assets = updatedAssetModel
        , player = Player 10 10 0 birdWatching 0
        }
        !
        [ Cmd.map AssetMsg assetMsg
        , Cmd.map AssetMsg spriteMsg
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AssetMsg assetMsg ->
            let
                (updatedAssets, newMsg) = Elmo8.Assets.update assetMsg model.assets
            in
                { model | assets = updatedAssets} ! [ Cmd.map AssetMsg newMsg]

view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [] [ toString model |> Html.text ]
        ]

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
