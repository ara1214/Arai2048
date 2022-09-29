module Puzzle exposing(..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing(..)
import Svg.Events exposing(..)
import Browser

main = Browser.sandbox{init=init, update=update, view=view}

type alias Model = List {x:Int, y:Int, n:Int} onoff→nに変更
type alias Possition = {x:Int, y:Int}
--今一つのピースのみ存在。listに書き換えると--x,y,onoffの3つのフィールドが存在
type Msg = Slide Possition --スライドする
--場所を返してくれる --入れ替えるスイッチ

init:Model
init = List.map(/i -> {x=modBy 5 i ,y=i//5 , n=i})--変更
      (List.range 0 24)
  {-[{x=1,y=1,onoff=False}
        ,{x=1,y=2,onoff=False}
        ,{x=1,y=3,onoff=False}
        ,{x=2,y=1,onoff=False}
        ,{x=2,y=2,onoff=Flase}
        ,{x=2,y=3,onoff=False}
        ,{x=3,y=1,onoff=False}
        ,{x=3,y=2,onoff=False}
        ,{x=3,y=3,onoff=False}]
-}
update: Msg -> Model -> Model
update msg model = --何もしない
  case msg of
    Slide pos -> slide model pos

slide: Model -> Position ->Model --taggleをslideに変更
slide model pos =
  let
      others = List.filter(/p -> not(p.x==pos.x && p.y==pos.y))model
      clicked = List.filter(/p -> (p.x==pos.x && p.y==pos.y))model
  in
  List.map (/pp -> if abs (pp.x==pos.x)^2 && (pp.y==pos.y)^2 == 1
                    && pp.n == 0 then
                    {pp|x =pos.x, y=pos.y}
                    else
                      pp
                    ) model
    --現在のonoff値をひっくり返して新しいonoffにしてください
    --xとyの値は変わらずonoffのみ切り替え
    --notはTrueだったらfalse falseだったらtrue

unit = 50

piece p =
        rect [x (String.fromInt (model.p.x*unit)) --中心x座標 StringfromIntは文字列に変換してくれるもの
                ,y (String.fromInt (model.p.y*unit)) --中心y座標
                ,width (String.fromInt unit)
                ,height (String.fromInt unit)
                ,rx(String.fromInt(unit//10))
                ,ry(String.fromInt(unit//10)) --四角形の丸みを帯びさせる
                ,fill (if p.n==0 then
                  "white"
                    else
                  "pink")
                ,onClick (Slide {x=p.x,y=p.y})]
                []


view: Model -> Html Msg
view model =
  svg[width "600"
      ,height "600"]
      --circleを全部書くのは大変なので関数に変更
      (List.map piece model)--circlというリストが4つ入ったものがかえってくる
