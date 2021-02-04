module Main exposing (main)

import Browser

import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


-- MAIN
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }

type alias Model =
    { content : String
    , decode : Bool
    , record : Maybe Record
    }


type Msg
    = Enter String
    | Submit


init : () -> ( Model, Cmd Msg )
init _ =
    ({ content = "{\"uid\": \"abcd-efgh\"}", decode = False, record = Nothing }, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Enter content ->
            ({ model | content = content, record = Nothing }, Cmd.none)

        Submit ->
            let
                result = JD.decodeString customDecoder model.content
            in
            case result of
                Ok record ->
                    ({ model | record = Just record }, Cmd.none)

                Err err ->
                    let
                        e =
                            Debug.log "Something failed" err
                    in
                        ({ model | record = Nothing }, Cmd.none)


type alias Record =
    { uid : String }


customDecoder : JD.Decoder Record
customDecoder =
    JD.succeed Record
        |> required "uid" JD.string


view : Model -> Html Msg
view model =
    H.div []
        [ H.textarea
            [ HE.onInput Enter
            , HA.rows 15
            , HA.cols 80
            ]
            [ H.text model.content ]
        , H.button [ HE.onClick Submit ] [ H.text "Decode" ]
        , case model.record of
            Just record ->
                H.div [] [ H.text <| "Uid:" ++ record.uid ]

            Nothing ->
                H.span [] []
        ]