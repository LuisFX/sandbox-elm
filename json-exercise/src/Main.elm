module Main exposing (..)

import Browser
import Html as H exposing (Html, div, hr, ul, li)
import Json.Decode as JD exposing (..)
import Post exposing (..)
import Http

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }

-- MODEL 
type Model
    = PostsLoaded (List Post)

-- VIEW

view : Model -> Html Msg
view model =
    div[][]

-- UPDATE

type Msg
    = Loading
    | GenerateRandom
    | LoadJsonPosts

update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateRandom ->
             ( model, Cmd.none ) --Cmd Msg )

        LoadJsonPosts ->
             ( getPosts , Cmd.none ) --Cmd Msg )

        Loading ->
            (model, Cmd.none)

getPosts =
    Http.get {
        url = "http://localhost:8000/posts.json"
        expect =
    }