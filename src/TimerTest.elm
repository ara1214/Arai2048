module TimerTest exposing (..)

import Browser
import Html exposeing(..)

import Random

main Browser.element{init=init
			               ,update=update
			                ,view = view
			                ,subscriptions = subscriptions}

type aleas Model = {config : Config
                    ,elapsedTime: Int}

type aleas Config = List Piece --Pieceが集まっている
type Piece = {x:Int, y:Int}

type Msg = Elapsed Time.Posix

init : () -> (Model, Cmd Msg)--これは組である必要がある
init _=
  {config=[{x=0,y=0}], elapsedTime=0}--ピースが一つ入っていて経過時間が0
  ,Cmd.nome)--何もしないという意味

update: Msg -> Model ->
  update msg model=
    case msg of
      Elapsed pt -> ({model | elaposedTime=model.elapsedTime+1 --タイムが1秒経過
                    , Cmd.none)

pieceView : Piece -> Svg Msg
pieceView p =
  rect[x
      ,y
      ,width
      ,height
      ,fill
      ,[]]

configView: Config -> List(Svg Msg)--要素がリストとして返される
configView config =
  List.map pieceView config --configはピース

view: Model -> Html Msg
view model =
  Html.div[]
    [
      svg[width "300"
          ,height "500"
          ]
          (configView model.config)
        ,Html.div[]
          [Html.text(String.fromInt model.elapsedTime+1
          ,Cmd.none)--モデルの中にあるものを文字列型に変換]
    ]

subscriptions: Model -> Sub msg
subscriptions model =
  Time.every 1000 Elapsed
    _
