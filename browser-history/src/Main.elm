module Main exposing (..)

import Browser
import Html exposing (Html, div,text,span,ul,li, h1, h2, h3)
import HistoryItem exposing (HistoryItem)
import Http exposing (get)
import HistoryItem exposing (historyItemsDecoder)

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }

init : () -> (Model, Cmd Msg)
init _ =
    ( Loading, getHistoryItems)

-- MODEL
type Model
    = HistoryItemsLoaded (List HistoryItem)
    | ErrorLoading String
    | Loading


-- UPDATE
type Msg
    = ReceivedHistoryItems (Result Http.Error (List HistoryItem))

update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedHistoryItems result ->
            case result of
                Ok hi ->
                    ( HistoryItemsLoaded hi, Cmd.none )
                Err e ->
                    (case e of
                        Http.BadUrl s -> "BAD_URL:" ++ s
                        Http.Timeout -> "TIMEOUT"
                        Http.NetworkError -> "NETWORK_ERROR"
                        Http.BadStatus i -> "BAD_STATUS: " ++ String.fromInt i
                        Http.BadBody s -> "BAD_BODY: " ++ s)
                    |> (\ error ->
                        ( ErrorLoading error, Cmd.none)
                    )

-- VIEWS

viewHistoryItems : (List HistoryItem) -> Html Msg
viewHistoryItems historyItems =
    div[][
        ul[]
            (
                historyItems
                |> List.map
                (\ i ->
                    li[][
                        h3[][text i.title]
                        
                    ]
                )
            )
    ]
view : Model -> Html Msg
view model =
    div [] [
        h1 [][text "Browser History"]
        ,    (
                case model of
                    Loading -> h2[][text "Loading..."]
                    ErrorLoading e ->
                        span[][text e]

                    HistoryItemsLoaded hi ->
                        viewHistoryItems hi
            )
        ]
     


-- HELPER FUNCTIONS --
----------------------

-- HTTP

getHistoryItems : Cmd Msg
getHistoryItems =
    get {
        url = "http://localhost:8001/BrowserHistory"
        , expect = Http.expectJson ReceivedHistoryItems historyItemsDecoder
    }