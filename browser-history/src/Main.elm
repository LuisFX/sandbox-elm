module Main exposing (..)

import Browser
import Html exposing (Html, div,text,span,ul,li, h1, h2, h3)
import HistoryItem exposing (HistoryItem)
import Http exposing (get)
import HistoryItem exposing (historyItemsDecoder)
import GoogleDestinations exposing (GoogleDestinations, googleDestinationsDecoder)
import Html exposing (button)
import Html.Events exposing (onClick)

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
    ( Loading, getGoogleDestinations)
    -- ( Loading, getHistoryItems)

-- MODEL
type Model
    = HistoryItemsLoaded (List HistoryItem)
    | GoogleDestinationsLoaded GoogleDestinations
    | ErrorLoading String
    | Loading

-- UPDATE
type Msg
    = ReceivedHistoryItems (Result Http.Error (List HistoryItem))
    | ReceivedGoogleDestinations (Result Http.Error GoogleDestinations)
    | FetchHistoryItems
    | FetchGoogleDestinations


update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchHistoryItems -> (Loading, getHistoryItems)
        FetchGoogleDestinations -> (Loading, getGoogleDestinations)
        ReceivedGoogleDestinations result ->
            case result of
                Ok payload ->
                    ( GoogleDestinationsLoaded payload, Cmd.none )
                Err e ->
                    ( ErrorLoading (getHttpErrorString e), Cmd.none)

        ReceivedHistoryItems result ->
            case result of
                Ok payload ->
                    ( HistoryItemsLoaded payload, Cmd.none )
                Err e ->
                    ( ErrorLoading (getHttpErrorString e), Cmd.none)

-- VIEWS

viewHistoryItems : (List HistoryItem) -> Html Msg
viewHistoryItems historyItems =
    div[][
        button [ onClick FetchGoogleDestinations] [ text "Switch To Google Destinations" ]
        ,div[][
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

    ]

viewGoogleDestinations : GoogleDestinations -> Html Msg
viewGoogleDestinations dest =
    div[][
        button [ onClick  FetchHistoryItems] [ text "Switch To History Items" ]
        ,div[]
            (
                dest.destinationAddresses
                |> List.map(\ d ->
                    span[][text d] 
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
                    
                    GoogleDestinationsLoaded destinations ->
                        viewGoogleDestinations destinations
            )
        ]
     


-- HELPER FUNCTIONS --
----------------------

-- HTTP

getGoogleDestinations : Cmd Msg
getGoogleDestinations =
    get {
        url = "http://localhost:8000/google.maps.json"
        , expect = Http.expectJson ReceivedGoogleDestinations googleDestinationsDecoder
    }


getHistoryItems : Cmd Msg
getHistoryItems =
    get {
        url = "http://localhost:8001/BrowserHistory"
        , expect = Http.expectJson ReceivedHistoryItems historyItemsDecoder
    }

getHttpErrorString : Http.Error -> String
getHttpErrorString error =
    case error of
        Http.BadUrl s -> "BAD_URL:" ++ s
        Http.Timeout -> "TIMEOUT"
        Http.NetworkError -> "NETWORK_ERROR"
        Http.BadStatus i -> "BAD_STATUS: " ++ String.fromInt i
        Http.BadBody s -> "BAD_BODY: " ++ s