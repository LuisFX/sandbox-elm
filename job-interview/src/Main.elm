module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)

import Post exposing (Post, postListDecoder)
import Html

-- MAIN
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- MODEL
type Model
  = Loading
  | PostsLoaded (List Post)
  | PostsFailedToLoad String


init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getPostsJson)

-- UPDATE
type Msg
  = GotPosts (Result Http.Error (List Post))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotPosts result ->
      case result of
        Ok postList ->
          (PostsLoaded postList, Cmd.none)
        Err e -> (
          case e of
            Http.BadUrl s -> "BAD_URL:" ++ s
            Http.Timeout -> "TIMEOUT"
            Http.NetworkError -> "NETWORK_ERROR"
            Http.BadStatus i -> "BAD_STATUS: " ++ String.fromInt i
            Http.BadBody s -> "BAD_BODY: " ++ s
          )
          |> (\ error -> (PostsFailedToLoad error, Cmd.none))
          

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Fakeagram" ]
    , div[][
        case model of
          PostsFailedToLoad e ->
            div [][text e]
          PostsLoaded posts ->
            viewPosts posts
          Loading ->
            h1 [][text "loading..."]
      ] 
    
    ]

viewPost : Post -> Html Msg
viewPost post =
  div[][
    ul[][
      li[][text post.id]
      ,li[][text post.text]
    ]
    , img [src  post.image, width 50, height 50 ][]
  ]

viewPosts : List Post -> Html Msg
viewPosts posts =
    div[][
      p [][text "Posts loaded successfully."]
      ,div [] (posts |> List.map (\ p -> viewPost p))
    ]

-- HTTP
getPostsJson = 
  Http.get {
    url = "http://localhost:8000/posts.json"
    , expect = Http.expectJson GotPosts postListDecoder
  }