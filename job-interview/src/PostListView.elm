module PostListView exposing (viewPosts)
import Browser
import Html exposing (..)
import Post exposing (Post)

-- VIEW

viewPost : Post -> Html Msg
viewPost post =
  li [] [text post.text]

viewPosts : Model -> Html Msg
viewPosts model =
  case model of
    PostsLoaded posts ->
      div[][
        h2 [][text "Posts loaded successfully."]
        ,ul [] (posts |> List.map (\ p -> viewPost p))
      ]
    PostsFailedToLoad e ->
      div [][text e]
    _ ->
      h2 [][text "OTHER ERROR"]