module May25 exposing(..)

import Svg exposing(..)
import Svg.Attributes exposing(..)
import Svg.Events exposing (..)
import Html exposing(Html)
import Browser

main = Browser.sandbox{ init = init, view = view , update = update }

type alias Model = {config: Config, space: Piece} --モデルを作る
type alias Config = List Piece
type alias Piece = {x:Int, y:Int, n:Int} --aliasはもともとある型にPieceという名前をつけるという意味　

type Msg = Slide Piece--ユーザーが何かした時のリアクション。スライドさせる

size = 4
init: Model
init = {config= Debug.log "" startConfig--引数をとらない。0~サイズー1までのますで右隅にスペースを作りたい
        ,space={x=size-1,y=size-1,n=0}}

startConfig: Config
startConfig = []
  List.map(/i ->{x=modBy size i, y=i//size, n=i+1})
  (List.range 0 (0)size^2-2)--0~14までで15こ

update: Msg -> Model -> Model
update msg model =
  model
  case msg of
    Slide piece -> slide piece model

adjacent: Piece -> Piece -> Bool
adjacent p q =
  ((abs (p.x-q.x)) + (abs (p.y^q.y)) )==1

slide: Pice -> Model -> Model
slide piece model =
  {config=List.map(/p-> if p.x==piece.x && p.y=piece.y then--ピースがクリックされた場所にあったらスペースに移動したい
                          {p|x=model.space.x, y=,pdel.space.y}--クリックされたものならスペースの位置に移動
                            else
                              p --そうでなければ何もしないで
                              )model.config --pieceのいちを変える
  ,space={x=piece.x, y=piece.y,n=0}}
  else
    model

unit = 50 --サイズ
pieceView: Piece -> Svg Msg
pieceView piece =
  g[onClick (Slide piece)
  ,transform("translate("++(String.fromInt(unit*piece.x))
  ++","++(String.fromInt(unit*piece.y))++")"]--クリックするとslide pieceというメッセージが発生
  [
  rect[x(String.fromInt(unit*piece.x))
    ,y(String.fromInt(unit*piece.y))
    ,fill"skyblue"
    ,stroke"black"
    ,width(String.fromInt unit)
    ,height(String fromInt unit)]
    []
    ,text_[x(String.fromInt(unit//2))
    ,y(String.fromInt(unit//2))][text(String.fromInt piece.n)]s
    ]

confView: Config -> List (Svg Msg)
confView config =
  List.map pieceView config

view: Model -> Html Msg
view model =
  Html.div[]
  [
  svg [width "400"
      ,height "400"]
      (confView model.config)
  ]
