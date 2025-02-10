-- xmonad config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config
-- customized per the xmonad tutorial to support xmonad-0.17
-- https://xmonad.org/TUTORIAL.html

import System.IO
import System.Exit
import XMonad
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Rescreen
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Magnifier
import XMonad.Layout.Renamed
import XMonad.Layout.ThreeColumns
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Xinerama
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified XMonad.DBus as D
import qualified DBus.Client as DC


------------------------------------------------------------------------
-- Terminal
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "/usr/bin/wezterm"

------------------------------------------------------------------------
-- move the cursor in the middle of a newly focused window
up = updatePointer (0.5, 0.5) (0, 0)

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
myWorkspaces = ["1:term","2:web","3:code","4:docs","5:media"] ++ map show [6..9]

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
myScratchpads = [
  NS "spotify" "flatpak run com.spotify.Client" (className =? "Spotify") (customFloating $ W.RationalRect (1/10) (1/10) (4/5) (4/5)),
  NS "obsidian" "flatpak run md.obsidian.Obsidian" (className =? "obsidian") (customFloating $ W.RationalRect (1/10) (1/10) (4/5) (4/5))
  ]

gsconfig1 = def { gs_cellheight = 80, gs_cellwidth = 250 }

-----------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "Firefox"        --> doShift "2:web"
    , resource  =? "desktop_window" --> doIgnore
    , className =? "sioyek"         --> doShift "4:docs"
    , className =? "evince"         --> doShift "4:docs"
    , className =? "Evince"         --> doShift "4:docs"
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)]


------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts (
    Tall nmaster delta ratio |||
    Mirror (Tall nmaster delta ratio) |||
    ThreeCol 1 (3/100) (1/3) |||
    renamed [Replace "ThreeCol"] (magnifiercz' 1.4 $ ThreeColMid nmaster delta ratio )) |||
    noBorders (fullscreenFull Full)
    where
        nmaster = 1       -- Default number of windows in the master pane
        ratio    = 1/2    -- Default proportion of screen occupied by master pane
        delta    = 3/100  -- Percent of screen to increment by when resizing panes


myFadeHook = composeAll [ opaque
                        , isUnfocused --> transparency 0.05
                        ]

------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod1Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
  [ ((modMask .|. shiftMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using xsecurelock.
  , ((modMask .|. controlMask, xK_l),
     spawn "xset s activate")

  -- Launch rofi
  -- Use this to launch programs without a key binding.
  , ((modMask, xK_p),
     spawn "rofi -show combi -combi-modi 'run,drun'")

  -- Launch passmenu
  , ((modMask, xK_o),
     spawn "bin/rofi_pass")

  -- Trigger Spotify scratchpad
  , ((modMask, xK_s),
     namedScratchpadAction myScratchpads "spotify")

  -- Trigger Obsidian scratchpad
  , ((modMask, xK_a),
     namedScratchpadAction myScratchpads "obsidian")

  -- Switch keyboard layout to the next one
  , ((controlMask .|. modMask, xK_k),
      spawn "xkb-switch -n")

  -- Take a screenshot in select mode.
  -- After pressing this key binding, click a window, or draw a rectangle with
  -- the mouse.
  , ((modMask .|. shiftMask, xK_p),
     spawn "select-screenshot")

  -- Take full screenshot in multi-head mode.
  -- That is, take a screenshot of everything you see.
  , ((modMask .|. controlMask .|. shiftMask, xK_p),
     spawn "scrot")

  -- Fetch a single use password.
  , ((modMask .|. shiftMask, xK_o),
     spawn "fetchotp -x")

  -- Mute volume.
  , ((0, 0x1008FF12),
     spawn "amixer -q set Master toggle")

  -- Decrease volume.
  , ((0, 0x1008FF11),
     spawn "amixer -q set Master 10%-")

  -- Increase volume.
  , ((0, 0x1008FF13),
     spawn "amixer -q set Master 10%+")

-- Decrease brightness.
  , ((0, 0x1008FF03),
     spawn "brightnessctl s 10%-")

-- Increase brightness.
  , ((0, 0x1008FF02),
     spawn "brightnessctl s +10%")

-- Toggle notifications.
  , ((controlMask, xK_F12),
     spawn "bin/toggle_notifications")

-- Trigger the GridSelect to pick a window
  , ((modMask, xK_g),
     goToSelected gsconfig1)

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_Tab),
     windows W.focusDown           >> up)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown           >> up)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp             >> up)

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster         >> up)

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster          >> up)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown            >> up)

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp              >> up)

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink            >> up)

  -- Expand the master area.
  , ((modMask, xK_l),
     sendMessage Expand            >> up)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1)    >> up)

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)) >> up)

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask, xK_q),
     restart "xmonad" True)
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
myStartupHook =  do
    spawn "~/.config/xmonad/session"

------------------------------------------------------------------------
-- Rescreen hook
-- Reconfigure screens when an output is (dis)connected.
--
-- myRandrChangeHook = do
--     spawn "echo ---------- >> ~/xrandr.output"
-- 
-- myRescreenCfg = def{
--     randrChangeHook = myRandrChangeHook
-- }

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  dbus <- D.connect
  D.requestAccess dbus
  xmonad
    $ docks
    $ addEwmhWorkspaceSort (pure (filterOutWs [scratchpadWorkspaceTag])) . ewmh
    $ ewmhFullscreen
    $ withEasySB (statusBarProp "polybar" (pure (myPolybarPP dbus))) defToggleStrutsKey
--    $ rescreenHook myRescreenCfg
    $ defaults


myPolybarPP :: DC.Client -> PP
myPolybarPP dbus = def
    { ppOutput = D.send dbus
    , ppTitle = shorten 40
    }

------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    borderWidth        = 0,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = "#eee8d5",
    focusedBorderColor = "#dc322f",

    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    handleEventHook    = handleEventHook def <+> fadeWindowsEventHook,
    logHook            = fadeWindowsLogHook myFadeHook,
    layoutHook         = smartBorders $ myLayout,
    manageHook         = myManageHook <+> namedScratchpadManageHook myScratchpads,
    startupHook        = myStartupHook
}
