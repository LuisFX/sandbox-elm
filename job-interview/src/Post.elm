module Post exposing (Post, postListDecoder)
import Json.Decode as Decode exposing (Decoder, int, string, float, list, field, bool, map3, maybe)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)

type alias Post =
    { id : String
    , text : String
    , likes : Int
    , image : Maybe String
    }

postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" string
        |> optional "text" string "bad post text"
        |> optional "likes" int 0
        |> optional "image" (maybe string) Nothing --"https://picsum.photos/50"

postListDecoder : Decoder (List Post)
postListDecoder =
    Decode.list postDecoder


-- type alias User =
--   { id : Int
--   , email : Maybe String
--   , name : String
--   , percentExcited : Float
--   }


-- userDecoder : Decoder User
-- userDecoder =
--   Decode.succeed User
--     |> required "id" int
--     |> required "email" (nullable string) -- `null` decodes to `Nothing`
--     |> optional "name" string "(fallback if name is `null` or not present)"
--     |> hardcoded 1.0

ageDecoder : Decoder Int
ageDecoder =
  field "age" int

type alias Job = { name : String, id : Int, completed : Bool }
point : Decoder Job
point =
  map3 Job
    (field "name" string)
    (field "id" int)
    (field "completed" bool)