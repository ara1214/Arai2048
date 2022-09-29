module HelloWorld exposing (main)

import Angle
import Camera3d
import Color
import Direction3d
import Html exposing (Html)
import Length
import Pixels
import Point3d
import Sphere3d
import Axis3d
import Scene3d
import Scene3d.Material as Material
import Viewpoint3d
import Browser
import Html exposing (Html)
import Time

main = Browser.element{init = init
                        ,update = update
                        ,view = view
                        ,subscriptions = subscriptions}

type alias Model = {angle: Float}
type Msg = Elapsed Time.Posix

init: () -> (Model, Cmd Msg)
init _ =
  (Model 0
  ,Cmd.none)

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Elapsed t -> ({model|angle=model.angle+1}, Cmd.none)


view: Model -> Html Msg
view model =
  main : Html msg
main =
    let
        -- Define a blue nonmetal (plastic or similar) material
        material = --材質
            Material.nonmetal
                { baseColor = Color.lightBlue
                , roughness = 0.4 -- varies from 0 (mirror-like) to 1 (matte)
                --0ならピカピカで1なら反射しない
                }

        -- Create a sphere entity using the defined material
        sphere =
            Scene3d.sphere material <|
                Sphere3d.withRadius (Length.meters 1) Point3d.origin
                --半径が1mの球面をorigin(0.0.0)で描く。Point3dに入れる
        satellite =
          Scene3d.rotateAround Axis3d.x(Angle.degrees model.angle)<|
          (Scane3d.sphere material <|
            Sphere3d.withRadius (Length.meters 1) Point3d.meters 0 1.2 0))--原点から1.2m離れたところに衛星をおく
        plane =
          Scane3d.quad materisal
            (Point3d.meters 1 1 0)
            (Point3d.meters -1 1 0)
            (Point3d.meters -1 -1 0)
            (Point3d.meters 1 -1 0)
        -- Define a camera as usual
        camera =
            Camera3d.perspective
                { viewpoint =
                    Viewpoint3d.lookAt
                        { focalPoint = Point3d.origin
                        , eyePoint = Point3d.meters 5 5 5  ---555と言う箇所から原点を見る
                        , upDirection = Direction3d.positiveZ
                        }
                , verticalFieldOfView = Angle.degrees 30---見る時の角度が30度
                }
    in
  Html.div[]
  [
      Scene3d.sunny
        { camera = camera
        , clipDepth = Length.centimeters 0.5--0.5より近いものはうつさない
        , dimensions = ( Pixels.int 600, Pixels.int 600 )--600*600のキャンバス(大きな球)
        , background = Scene3d.transparentBackground--陽明な背景
        , entities = [ sphere,plane,satellite ]

        -- Specify that sunlight should not cast shadows (since we wouldn't see
        -- them anyways in this scene)
        , shadows = False--影をつけるかつけないか

        -- Specify the global up direction (this controls the orientation of
        -- the sky light)
        , upDirection = Direction3d.z

        -- Specify the direction of incoming sunlight (note that this is the
        -- opposite of the direction *to* the sun)
        , sunlightDirection = Direction3d.yz (Angle.degrees -120)--太陽がどこから照りつけるか
      }
      ]

subscriptions: Model -> Sub Msg
subscriptions =
    Time.every 10 Elapsed --0.1sごと
