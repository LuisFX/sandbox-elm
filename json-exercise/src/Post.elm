module Post exposing (Post, postListDecoder)
import Json.Decode as JD exposing (..)
import Json.Decode.Pipeline as JDP exposing (..)
type alias Post =
    {
        id : String
        ,name : String
    }

postDecoder : Decoder Post
postDecoder =
    JD.succeed Post
        |> required "id" string
        |> required "name" string

postListDecoder : Decoder (List Post)
postListDecoder =
    list postDecoder