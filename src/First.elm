module Main exposing (..)

import Browser
import Html exposing (..)
--Html.が必要なくなる
import Html.Events exposing(..)

main = Browser.sandbox {init=0, update=update, view=view} --modelは0

type Msg = Plus | Minus
type alias Model = Int


--update
update: Msg -> Model -> Model --メッセージを受け取ったらモデルを受け取り新しいモデルを返す
update msg model =
  case msg of
    Plus -> model + 1 --clickというメッセージが来たらmodelを1増やしなさい
    Minus -> model - 1 --clickというメッセージが来たらmodelを1減らしなさい

--view　ウェブブラウザの画面を構成 HTMLページとして表示
view: Model -> Html Msg --Modelを受けっとたらMsgを返す
view model =
  div [] [button [onClick Plus] [text "+"] --buttonnは+でtextはモデルの値
          ,button[onClick Minus][text "-"]
          ,text(String.fromInt model)]
--onclick クリックを押したらplus or minusというメッセージを発生する->足しひきが行われる
