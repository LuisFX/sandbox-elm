-- To decode the JSON data, add this file to your project, run
--
--     elm-package install NoRedInk/elm-decode-pipeline
--
-- add these imports
--
--     import Json.Decode exposing (decodeString)`);
--     import GoogleDestinations exposing (googleDestinations)
--
-- and you're off to the races with
--
--     decodeString googleDestinations myJsonString

module GoogleDestinations exposing
    ( GoogleDestinations
    , googleDestinationsToString
    , googleDestinations
    , Row
    , Element
    , Distance
    )

import Json.Decode as Jdec
import Json.Decode.Pipeline as Jpipe
import Json.Encode as Jenc
import Dict exposing (Dict, map, toList)
import List exposing (map)

type alias GoogleDestinations =
    { destinationAddresses : List String
    , originAddresses : List String
    , rows : List Row
    , status : String
    }

type alias Row =
    { elements : List Element
    }

type alias Element =
    { distance : Distance
    , duration : Distance
    , status : String
    }

type alias Distance =
    { text : String
    , value : Int
    }

-- decoders and encoders

googleDestinationsToString : GoogleDestinations -> String
googleDestinationsToString r = Jenc.encode 0 (encodeGoogleDestinations r)

googleDestinations : Jdec.Decoder GoogleDestinations
googleDestinations =
    Jpipe.decode GoogleDestinations
        |> Jpipe.required "destination_addresses" (Jdec.list Jdec.string)
        |> Jpipe.required "origin_addresses" (Jdec.list Jdec.string)
        |> Jpipe.required "rows" (Jdec.list row)
        |> Jpipe.required "status" Jdec.string

encodeGoogleDestinations : GoogleDestinations -> Jenc.Value
encodeGoogleDestinations x =
    Jenc.object
        [ ("destination_addresses", makeListEncoder Jenc.string x.destinationAddresses)
        , ("origin_addresses", makeListEncoder Jenc.string x.originAddresses)
        , ("rows", makeListEncoder encodeRow x.rows)
        , ("status", Jenc.string x.status)
        ]

row : Jdec.Decoder Row
row =
    Jpipe.decode Row
        |> Jpipe.required "elements" (Jdec.list element)

encodeRow : Row -> Jenc.Value
encodeRow x =
    Jenc.object
        [ ("elements", makeListEncoder encodeElement x.elements)
        ]

element : Jdec.Decoder Element
element =
    Jpipe.decode Element
        |> Jpipe.required "distance" distance
        |> Jpipe.required "duration" distance
        |> Jpipe.required "status" Jdec.string

encodeElement : Element -> Jenc.Value
encodeElement x =
    Jenc.object
        [ ("distance", encodeDistance x.distance)
        , ("duration", encodeDistance x.duration)
        , ("status", Jenc.string x.status)
        ]

distance : Jdec.Decoder Distance
distance =
    Jpipe.decode Distance
        |> Jpipe.required "text" Jdec.string
        |> Jpipe.required "value" Jdec.int

encodeDistance : Distance -> Jenc.Value
encodeDistance x =
    Jenc.object
        [ ("text", Jenc.string x.text)
        , ("value", Jenc.int x.value)
        ]

--- encoder helpers

makeListEncoder : (a -> Jenc.Value) -> List a -> Jenc.Value
makeListEncoder f arr =
    Jenc.list (List.map f arr)

makeDictEncoder : (a -> Jenc.Value) -> Dict String a -> Jenc.Value
makeDictEncoder f dict =
    Jenc.object (toList (Dict.map (\k -> f) dict))

makeNullableEncoder : (a -> Jenc.Value) -> Maybe a -> Jenc.Value
makeNullableEncoder f m =
    case m of
    Just x -> f x
    Nothing -> Jenc.null
