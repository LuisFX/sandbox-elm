module HistoryItem exposing (HistoryItem, historyItemsDecoder)

import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline as JDP exposing (..)

type alias HistoryItem =
    {
        -- pageTransition: String
        title : String
        , url : String
        -- ,clientId : String
        -- ,timeUsec : Int
    }

historyItemDecoder : Decoder HistoryItem
historyItemDecoder =
    succeed HistoryItem
        -- |> required "page_transition" string
        |> required "title" string
        |> required "url" string
        -- |> required "client_id" string
        -- |> required "time_usec" int

historyItemsDecoder : Decoder (List HistoryItem)
historyItemsDecoder =
    list historyItemDecoder
    