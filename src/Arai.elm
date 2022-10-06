module Arai exposing(..)

import Browser
import Svg exposing(..)
import Svg.Attributes exposing(..)
import Svg.Events exposing(..)
import Html exposing (Html)
import Json.Decode
import Random
import Html.Events.Extra.Pointer as Pointer
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P


main = Browser.element {init=init
                       ,update=update
                       ,view=view
                       ,subscriptions=subscriptions
                       }
type alias Coord = {x:Int
                    ,y:Int
                    }

type alias Piece = {x:Int
                   ,y:Int
                   ,d:Int
                   }
type alias Model = {conf: List Piece
                    ,startAt: {x:Float,y:Float}}

type Msg = Up
         |Down
         |Left
         |Right
         |RandAdd Int
         |PDown Pointer.Event
         |PUp Pointer.Event

init: () -> (Model, Cmd Msg)
init _ = (
        {conf=
        [{x=3,y=2,d=4}
        ,{x=2,y=2,d=4}
        ,{x=2,y=3,d=2}
        ,{x=1,y=1,d=2}
        ]
        ,startAt={x=0,y=0}}
       ,Cmd.none
       )

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Up -> ({model|conf=up model.conf}
              , Random.generate RandAdd
                  (Random.int 1 (16 - (List.length <| up model.conf)))
              )
        Down -> ({model|conf=down model.conf}
                   , Random.generate RandAdd
                       (Random.int 1 (16 - (List.length <| down model.conf)))
                   )
        Right -> ({model|conf=right model.conf}
                 , Random.generate RandAdd
                     (Random.int 1 (16 - (List.length <| right model.conf)))
                 )
        Left -> ({model|conf=left model.conf}
                 , Random.generate RandAdd
                     (Random.int 1 (16 - (List.length <| left model.conf)))
                 )
        RandAdd place -> (put 2 place model, Cmd.none)
        PDown event ->
          let
              px = Tuple.first event.pointer.offsetPos
              py = Tuple.second event.pointer.offsetPos
              dummy = Debug.log "Down" (px,py)
          in
              ({model | startAt={x=px,y=py}},Cmd.none)
        PUp event ->
          let
              px = Tuple.first event.pointer.offsetPos
              py = Tuple.second event.pointer.offsetPos
              vx=px-model.startAt.x
              vy=py-model.startAt.y

          in
              if vx>0 && vx > vy && vy > -vx then
                ({model|conf=right model.conf}
                , Random.generate RandAdd
                (Random.int 1 (16 - (List.length <| right model.conf)))
                )
              else if vx<0 && vx < vy && vy < -vx then
                ({model|conf=left model.conf}
                , Random.generate RandAdd
                (Random.int 1 (16 - (List.length <| left model.conf)))
                )
              else if vy>0 && vy>vx && vy > -vx then
                ({model|conf=down model.conf}
                , Random.generate RandAdd
                (Random.int 1 (16 - (List.length <| down model.conf)))
                )
              else if vy<0 && vy<vx && vy < -vx then
                ({model|conf=up model.conf}
                , Random.generate RandAdd
                (Random.int 1 (16 - (List.length <| up model.conf)))
                )
              else
                (model,Cmd.none)

direction: Float->Float->Msg
direction vx vy =
  Right
find: Coord -> Model -> Bool
find coord model =
    (List.length <| List.filter (\m -> coord.x==m.x && coord.y==m.y) model.conf) >= 1

put: Int -> Int -> Model -> Model
put digit place model =
    let
        full = List.concat <|
               List.map (\x -> List.map (\y->{x=x,y=y}) (List.range 0 3))<|
                   List.range 0 3
        rest = List.filter (\c -> not <| find c model) full
        coord = Maybe.withDefault {x=0,y=0} <| List.head <| List.drop (place-1) rest
    in
        {model|conf={x=coord.x, y=coord.y, d=digit} :: model.conf}

splitX: List Piece -> List (List Piece)
splitX conf =
    Debug.log "splitx:" <| List.map (\x -> List.filter (\digit -> digit.x==x)  conf)
        (List.range 0 3)
splitY: List Piece -> List (List Piece)
splitY conf =
    Debug.log "splity:" <| List.map (\y -> List.filter (\digit -> digit.y==y)  conf)
        (List.range 0 3)

rmDup: List Piece -> List Piece
rmDup line =
    let
        h = Maybe.withDefault {x=0,y=0,d=0} <| List.head line
        t = List.drop 1 line
        n = Maybe.withDefault {x=0,y=0,d=1} <| List.head t
    in
        if (List.length line) == 0 then
            []
        else if (List.length t) == 0 then
                 [h]
             else if h.d == n.d && (abs ((h.x-n.x)+(h.y-n.y))) ==1 then
                      List.concat [[{h | d = 2*h.d}], (rmDup (List.drop 1 t))]
                  else
                      List.concat [[h], (rmDup t)]


moveUp col =
    let
        sorted =  rmDup <| List.sortBy .y col
    in
        List.indexedMap (\idx digit -> {digit | y=idx}) sorted

moveDown col =
    let
        sorted = rmDup <| List.reverse <| List.sortBy .y col
    in
        List.indexedMap (\idx digit -> {digit | y=3-idx}) sorted

moveRight row =
    let
        sorted = rmDup <| List.reverse <| List.sortBy .x row
    in
        List.indexedMap (\idx digit -> {digit | x=3-idx}) sorted

moveLeft row =
    let
        sorted = rmDup <| List.sortBy .x row
    in
        List.indexedMap (\idx digit -> {digit | x=idx}) sorted

up conf =
    Debug.log "up:" <| List.concat <| List.map moveUp (splitX conf)

down conf =
    Debug.log "down:" <| List.concat <| List.map moveDown (splitX conf)

right conf =
    Debug.log "right:" <| List.concat <| List.map moveRight (splitY conf)

left conf =
    Debug.log "left:" <| List.concat <| List.map moveLeft (splitY conf)


panel digit =
    let
        color =
            case digit.d of
                2 -> "#da8"
                4 -> "#dc8"
                8 -> "#df8"
                _ -> "#fff"
    in
    g []
        [
         rect [x (String.fromInt (digit.x*50))
              ,y (String.fromInt (digit.y*50))
              ,fill color
              ,fillOpacity "0.5"
              ,width "50"
              ,height "50"
              ,stroke "gray"
              ,strokeWidth "5"
              ]
             []
        , text_ [x (String.fromInt (digit.x*50+25))
              ,y (String.fromInt (digit.y*50+25))
               ]
            [text (String.fromInt digit.d)]
        ]
cell pos =
    rect [x (String.fromInt (pos.x*50))
         ,y (String.fromInt (pos.y*50))
         ,width "50"
         ,height "50"
         ,fill "none"
         ,stroke "gray"
         ]
        []

buttonUp =
    g[transform "translate(100 250)"
     ,onClick Up
     ]
        [
         (rect [x "0"
               ,y "0"
               ,width "50"
               ,height "50"
               ,fill "#fff"
               ,stroke "black"
              ]
             [])
        ,(text_ [x "10"
               ,y "35"
                ,fontSize "30"
                ,fill "#aaf"
               ]
             [text "⬆"])
        ]

buttonDown =
    g[transform "translate(100 350)"
     ,onClick Down
     ]
        [
         (rect [x "0"
               ,y "0"
               ,width "50"
               ,height "50"
               ,fill "#fff"
               ,stroke "black"
              ]
             [])
        ,(text_ [x "10"
               ,y "35"
                ,fontSize "30"
                ,fill "#aaf"
               ]
             [text "⬇"])
        ]


buttonRight =
    g[transform "translate(150 300)"
     ,onClick Right]
        [
         (rect [x "0"
               ,y "0"
               ,width "50"
               ,height "50"
               ,fill "#fff"
               ,stroke "black"
              ]
             [])
        ,(text_ [x "10"
               ,y "35"
                ,fontSize "30"
                ,fill "#aaf"
               ]
             [text "➡"])
        ]

buttonLeft =
    g[transform "translate(50 300)"
     ,onClick Left
     ]
    [
     (rect [x "0"
           ,y "0"
           ,width "50"
           ,height "50"
           ,fill "#fff"
           ,stroke "black"
           ]
          [])
    ,(text_ [x "10"
            ,y "35"
            ,fontSize "30"
            ,fill "#aaf"
            ]
          [text "⬅"])
    ]
myOnDown : (Pointer.Event -> msg) -> Html.Attribute msg
myOnDown =
    { stopPropagation = False, preventDefault = True }
        |> Pointer.onWithOptions "pointerdown"

view model =
  Html.div[]
    [svg [width "600"
        ,height "600"
        ,myOnDown (\event -> PDown event)
        ,Pointer.onUp (\event -> PUp event)
        ]<|
        List.concat  [
             [rect [x "0"
                   ,y "0"
                   ,width "200"
                   ,height "200"
                   ,stroke "none"
                   ,fill "#ccc"
                   ]
                  []
             ]
             ,List.concat <| (List.map
                                  (\x -> List.map (\y->cell {x=x, y=y}) (List.range 0 3))
                                  (List.range 0 3))
            --,[buttonUp, buttonLeft, buttonRight, buttonDown]
             ,(List.map panel model.conf)
            ]
        ,Html.text((String.fromFloat model.startAt.x)++","++(String.fromFloat model.startAt.y))
        ]
relativePos : Pointer.Event -> ( Float, Float )
relativePos event =
    event.pointer.offsetPos

subscriptions: Model -> Sub Msg
subscriptions model  =
    Sub.none
