Injectable camera for Greedfall (Microsoft Store/Xbox Game Pass version only)
============================

This is a ported version of [Injectable camera for Greedfall by Frans Bouma (aka otis_inf)](https://github.com/FransBouma/InjectableGenericCameraSystem/tree/master/Cameras/Greedfall). This camera can be used with ONLY Microsoft Store/Xbox Game Pass version of the game. If you run the game on Steam or other platform, you must use the original camera.

### General Info/Features
Please refer [Injectable camera for Greedfall by Frans Bouma (aka otis_inf)](https://github.com/FransBouma/InjectableGenericCameraSystem/tree/master/Cameras/Greedfall).


### Supported game version
1.0.10 (as of 15th Jun 2021)


### Key assignments
#### General
Control | Kyeboard & Mouse | Xbox Controller
------------ | ------------- | -------------
Show / Hide Cameraa tools main window | Ctrl + Insert | N/A
Enable / Disable camera | Insert | N/A
Resize font | Control + Mouse wheel | N/A
Lock / Unlock camera movement | Home | N/A
Block input to gaame | Numpad Decimal(.) | N/A
Pause / Unpause game | Numpad 0 | N/A

#### Camera control
Control | Kyeboard & Mouse | Xbox Controller
------------ | ------------- | -------------
Rotate camera up | Up arrow or mouse | Right stick Y-axis
Rotate camera down  | Down arrow or mouse | Right stick Y-axis
Rotate camera left | Left arrow or mouse | Right stick X-axis
Rotate camera Right  | Right arrow or mouse | Right stick X-axis
Move camera forward | Numpad 8 | Left stick Y-axis
Move camera backward | Numpad 5 | Left stick Y-axis
Move camera left | Numpad 4 | Left stick X-axis
Move camera Right | Numpad 6 | Left stick X-axis
Move camera up | Numpad 7 | Left trigger(LT)
Move camera down | Numpad 9 | Right trigger(RT)
Tilt camera left | Numpad 1 | D-pad left
Tilt camera right | Numpad 3 | D-pad right
Faster rotate/move | Alt + rotate/move | Y button + Right/Left stick
Slower rotate/move | Ctrl + rotate/move | X button + Right/Left stick

#### FOV manipulation
Control | Kyeboard & Mouse | Xbox Controller
------------ | ------------- | -------------
Increase FOV | Numpad + | D-pad up
Decrease FOV | Numpad - | D-pad down
Reset FOV | Numpad * | B button

#### Screenshot
Control | Kyeboard & Mouse | Xbox Controller
------------ | ------------- | -------------
Test multi-screenshot setup | End | N/A
Take multi-screenshot | Ctrl + End | N/A
Take screenshot | Pause | N/A


### HUD toggle
There is no HUD toggle tool for Microsoft Store/Xbox Game Pass version. But you can disable HUD in-game options.
* Options -> Game -> Combat UI -> None or Minimal
* Options -> Game -> Exploration UI -> None or Minimal


### How to build
You need Visual Studio 2019.
1. Open the solution file CameraTools.sln in Cameras\GreedFallMS
2. Build the solution
3. You will get the DLL file GreedFallMSCameraTools.dll in Cameras\GreedFallMS\bin\x64\[Release|Debug]

### How to run
1. Launch GreedFall
2. When you can see the main menu, run IGCSInjector.exe
If the camera is injected successfully, you will see the credit in upper left corner on your screen.

### Changelog
15-Jun-2021 First releasae

### Acknowledgements
[Injectable Generic Camera System by Frans Bouma](https://github.com/FransBouma/InjectableGenericCameraSystem)